from fastapi import APIRouter, Depends, HTTPException, Form, UploadFile, File
from sqlalchemy.orm import Session
from models import Faculty, Attendance
from database import get_db
from datetime import datetime
from tempfile import NamedTemporaryFile
import os
import cv2
import torch
import torch.nn as nn
import torchvision.transforms as transforms
import torchvision.models as models
from deepface import DeepFace

router = APIRouter()

# 1. Load Anti-Spoofing Model

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model = models.mobilenet_v2(pretrained=False)
model.classifier[1] = nn.Linear(model.last_channel, 2)
model.load_state_dict(torch.load("model/best_antispoof_model.pth", map_location=device))
model.to(device)
model.eval()

# 2. Define Image Transform for Anti-Spoofing

test_transform = transforms.Compose([
    transforms.ToPILImage(),
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

# 3. Anti-Spoofing Check Function

def predict_spoof(image_path: str) -> bool:
    img = cv2.imread(image_path)
    if img is None:
        return False  # Invalid image

    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img_tensor = test_transform(img).unsqueeze(0).to(device)
    
    with torch.no_grad():
        outputs = model(img_tensor)
        _, predicted = torch.max(outputs, 1)

    return predicted.item() == 1  # 1 => Real, 0 => Spoofed

# 4. Mark Attendance API

@router.post("/attendance/")
async def mark_attendance(
    faculty_id: str = Form(...),
    image: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    faculty = db.query(Faculty).filter(Faculty.faculty_id == faculty_id).first()

    if not faculty:
        raise HTTPException(status_code=404, detail=f"No faculty found with ID: {faculty_id}")
    
    if not faculty.image:
        raise HTTPException(status_code=400, detail=f"No image found for faculty ID: {faculty_id}")

    uploaded_image_data = await image.read()

    temp_uploaded_path = None
    temp_stored_path = None  

    try:
        # Save uploaded image to a temp file
        with NamedTemporaryFile(delete=False, suffix=".jpg") as temp_uploaded:
            temp_uploaded.write(uploaded_image_data)
            temp_uploaded_path = temp_uploaded.name  

        # Save stored image to a temp file
        with NamedTemporaryFile(delete=False, suffix=".jpg") as temp_stored:
            temp_stored.write(faculty.image)
            temp_stored_path = temp_stored.name  

        print(f"DEBUG: Temp Uploaded Path: {temp_uploaded_path}")
        print(f"DEBUG: Temp Stored Path: {temp_stored_path}")

        # **Perform Anti-Spoofing Check**
        if not predict_spoof(temp_uploaded_path):
            os.remove(temp_uploaded_path)
            os.remove(temp_stored_path)
            raise HTTPException(status_code=400, detail="Spoofed image detected! Attendance not marked.")

        # **Perform Face Verification**
        try:
            result = DeepFace.verify(
                img1_path=temp_uploaded_path,
                img2_path=temp_stored_path,
                model_name="Facenet512"
            )
        except Exception as e:
            print(f"Face verification failed: {e}")
            raise HTTPException(status_code=500, detail=f"Error during face verification: {e}")

        if not result["verified"]:
            os.remove(temp_uploaded_path)
            os.remove(temp_stored_path)
            raise HTTPException(status_code=401, detail="Face recognition failed. Unauthorized.")

        # **Mark Attendance**
        current_time = datetime.now()
        today_date = current_time.date()

        attendance_record = (
            db.query(Attendance)
            .filter(Attendance.faculty_id == faculty_id)
            .filter(Attendance.date == today_date)
            .first()
        )

        if attendance_record:
            attendance_record.logout_time = current_time
            attendance_record.status = "Present"
        else:
            attendance_record = Attendance(
                faculty_id=faculty_id,
                status="Present",
                login_time=current_time,
                logout_time=None,
                date=today_date,
            )
            db.add(attendance_record)

        db.commit()
        db.refresh(attendance_record)

        return {
            "message": "Attendance marked successfully",
            "faculty_id": faculty_id,
            "faculty_name": faculty.name,
            "status": attendance_record.status,
            "date": str(today_date),
            "time": str(current_time),
        }

    finally:
        # Cleanup: Only delete if file exists
        if temp_uploaded_path and os.path.exists(temp_uploaded_path):
            print(f"DEBUG: Deleting temp file {temp_uploaded_path}")
            os.remove(temp_uploaded_path)

        if temp_stored_path and os.path.exists(temp_stored_path):
            print(f"DEBUG: Deleting temp file {temp_stored_path}")
            os.remove(temp_stored_path)
