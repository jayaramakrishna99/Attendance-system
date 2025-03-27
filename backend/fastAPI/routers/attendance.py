from fastapi import APIRouter, Depends, HTTPException, Form, UploadFile, File # type: ignore
from sqlalchemy.orm import Session # type: ignore
from sqlalchemy.sql import func # type: ignore
from models import Faculty, Attendance, Location
from database import get_db
from datetime import datetime,  timedelta ,date
from tempfile import NamedTemporaryFile
from deepface import DeepFace # type: ignore
import os
from .antispoofing import predict_spoof
from .polygon import POLYGON
from .location_utils import is_point_in_polygon
from datetime import timezone

router = APIRouter()

#  Mark Attendance API

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
    
    today_date = date.today()

    latest_location = (
        db.query(Location)
        .filter(
            Location.employee_id == faculty_id,
            func.date(Location.updated_at) == today_date 
        )
        .first()
    )

    if not latest_location:
        raise HTTPException(status_code=401, detail="Location not found. Please login again.")
    
    is_inside = is_point_in_polygon(
        latest_location.latitude,
        latest_location.longitude,
        POLYGON
    )

    if not is_inside:
        raise HTTPException(status_code=405, detail="You are outside the permitted area. Attendance cannot be marked.")

    current_time = datetime.now()
    location_time = latest_location.updated_at
    time_difference = current_time - location_time

    min_time_difference = 5 # minutes

    if time_difference > timedelta(minutes=min_time_difference):
        raise HTTPException(status_code=440, detail="Session expired. Please login again.")
        

    uploaded_image_data = await image.read()

    temp_uploaded_path = None
    temp_stored_path = None  

    try:
        with NamedTemporaryFile(delete=False, suffix=".jpg") as temp_uploaded:
            temp_uploaded.write(uploaded_image_data)
            temp_uploaded_path = temp_uploaded.name  

        with NamedTemporaryFile(delete=False, suffix=".jpg") as temp_stored:
            temp_stored.write(faculty.image)
            temp_stored_path = temp_stored.name  

        print(f"DEBUG: Temp Uploaded Path: {temp_uploaded_path}")
        print(f"DEBUG: Temp Stored Path: {temp_stored_path}")

        # Perform Anti-Spoofing Check
        if not predict_spoof(temp_uploaded_path):
            os.remove(temp_uploaded_path)
            os.remove(temp_stored_path)
            raise HTTPException(status_code=400, detail="Spoofed image detected! Attendance not marked.")

        # Perform Face Verification
        try:
            result = DeepFace.verify(
                img1_path=temp_uploaded_path,
                img2_path=temp_stored_path,
                model_name="Facenet512",
                detector_backend = "retinaface"
            )
        except Exception as e:
            print(f"Face verification failed: {e}")
            raise HTTPException(status_code=500, detail=f"Error during face verification: {e}")

        if not result["verified"]:
            os.remove(temp_uploaded_path)
            os.remove(temp_stored_path)
            raise HTTPException(status_code=406, detail="Face recognition failed. Unauthorized.")

        # Mark Attendance
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
        if temp_uploaded_path and os.path.exists(temp_uploaded_path):
            print(f"DEBUG: Deleting temp file {temp_uploaded_path}")
            os.remove(temp_uploaded_path)

        if temp_stored_path and os.path.exists(temp_stored_path):
            print(f"DEBUG: Deleting temp file {temp_stored_path}")
            os.remove(temp_stored_path)
