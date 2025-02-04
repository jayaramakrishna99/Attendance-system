from fastapi import APIRouter, Depends, HTTPException, Form, UploadFile, File
from sqlalchemy.orm import Session
from models import Faculty, Attendance
from database import get_db
from datetime import datetime
from tempfile import NamedTemporaryFile
import os
from deepface import DeepFace


router = APIRouter()

@router.post("/attendance/")
async def mark_attendance(
    faculty_id: str = Form(...),
    image: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    # Step 1: Retrieve the faculty record
    faculty = db.query(Faculty).filter(Faculty.faculty_id == faculty_id).first()

    if not faculty:
        raise HTTPException(status_code=404, detail=f"No faculty found with ID: {faculty_id}")
    
    if not faculty.image:
        raise HTTPException(status_code=400, detail=f"No image found for faculty ID: {faculty_id}")

    # Step 2: Read the uploaded image
    uploaded_image_data = await image.read()

    # Step 3: Save uploaded and stored images as temporary files
    with NamedTemporaryFile(delete=False, suffix=".jpg") as temp_uploaded:
        temp_uploaded.write(uploaded_image_data)
        temp_uploaded_path = temp_uploaded.name

    with NamedTemporaryFile(delete=False, suffix=".jpg") as temp_stored:
        temp_stored.write(faculty.image)
        temp_stored_path = temp_stored.name

    # Step 4: **Perform Anti-Spoofing Check**
    try:
        face_objs = DeepFace.extract_faces(img_path=temp_uploaded_path, anti_spoofing=True)

        # If any face is spoofed, throw an exception
        if not all(face_obj["is_real"] for face_obj in face_objs):
            os.remove(temp_uploaded_path)
            os.remove(temp_stored_path)
            raise HTTPException(status_code=400, detail="Spoofed image detected! Attendance not marked.")
    
    except Exception as e:
        os.remove(temp_uploaded_path)
        os.remove(temp_stored_path)
        raise HTTPException(status_code=500, detail=f"Error during anti-spoofing check: {e}")

    # Step 5: **Perform DeepFace Face Verification**
    try:
        result = DeepFace.verify(
            img1_path=temp_uploaded_path,
            img2_path=temp_stored_path,
            model_name="Facenet512"
        )
    except Exception as e:
        os.remove(temp_uploaded_path)
        os.remove(temp_stored_path)
        raise HTTPException(status_code=500, detail=f"Error during face verification: {e}")

    # Clean up temp files
    os.remove(temp_uploaded_path)
    os.remove(temp_stored_path)

    if not result["verified"]:
        raise HTTPException(status_code=401, detail="Face recognition failed. Unauthorized.")

    # Step 6: **Mark Attendance**
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
