from fastapi import FastAPI, UploadFile, Form, HTTPException
from fastapi.responses import JSONResponse, Response 
from sqlalchemy import create_engine, Column, Integer, String, LargeBinary, DateTime, Date, Enum, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from datetime import datetime, date
import aiofiles
import os
from deepface import DeepFace
import numpy as np
import cv2

# Database setup
DATABASE_URL = "mysql+pymysql://root:root123@localhost:3306/attendance_system"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=True, bind=engine)
Base = declarative_base()

# FastAPI app
app = FastAPI()

# Define database models
class Faculty(Base):
    __tablename__ = "faculty"
    id = Column(Integer, primary_key=True, index=True)
    faculty_id = Column(String(50), unique=True, index=True, nullable=False)
    name = Column(String(100), nullable=False)
    image = Column(LargeBinary, nullable=False)

class Attendance(Base):
    __tablename__ = "attendance"
    id = Column(Integer, primary_key=True, index=True)
    faculty_id = Column(String(50), nullable=False)
    status = Column(String(20), nullable=False)
    login_time = Column(String(20), nullable=True)
    logout_time = Column(String(20), nullable=True)
    date = Column(String(20), nullable=False)


# Create tables in the database
Base.metadata.create_all(bind=engine)

@app.post("/api/register/")
async def submit_data(
    id: str = Form(...),
    name: str = Form(...),
    image: UploadFile = None
):
    try:
        image_path = f"uploads/{image.filename}"
        # Save image to database
        async with aiofiles.open(f"uploads/{image.filename}", "wb") as out_file:
            content = await image.read()
            await out_file.write(content)
        
        try:
            face_objs = DeepFace.extract_faces(img_path=image_path, anti_spoofing=True)

            # Check if all detected faces are real
            if not all(face_obj["is_real"] for face_obj in face_objs):
                return JSONResponse(content={"error": "Spoofed image detected! Registration denied."}, status_code=400)

        except Exception as deepface_error:
            return JSONResponse(content={"error": f"Face detection failed: {str(deepface_error)}"}, status_code=500)
        # Insert data into the database
        db = SessionLocal()
        faculty = Faculty(faculty_id=id, name=name, image=content)
        db.add(faculty)
        db.commit()
        db.close()

        return JSONResponse(content={"message": "Faculty registered successfully"}, status_code=200)
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)


from tempfile import NamedTemporaryFile
def get_db():
    db=SessionLocal()
    try:
        yield db
    finally:
        db.close()
from typing import List,Annotated
from fastapi import Depends,Form,File,UploadFile
db_dependency=Annotated[Session,Depends(get_db)]
from fastapi import Depends, File, HTTPException
@app.post("/api/attendance/")
async def mark_attendance(
    faculty_id: str=Form(...),
    image: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    # Step 1: Retrieve the faculty record using the provided ID
    faculty = db.query(Faculty).filter(Faculty.faculty_id == faculty_id).first()

    if not faculty:
        raise HTTPException(
            status_code=404, detail=f"No faculty found with ID: {faculty_id}"
        )

    if not faculty.image:
        raise HTTPException(
            status_code=400, detail=f"No image found for faculty ID: {faculty_id}"
        )

    # Step 2: Read the uploaded image
    uploaded_image_data = await image.read()

    # Step 3: Save uploaded image and stored image as temporary files
    with NamedTemporaryFile(delete=False, suffix=".jpg") as temp_uploaded:
        temp_uploaded.write(uploaded_image_data)
        temp_uploaded_path = temp_uploaded.name

    with NamedTemporaryFile(delete=False, suffix=".jpg") as temp_stored:
        temp_stored.write(faculty.image)
        temp_stored_path = temp_stored.name

    #-------  Anti Spoofing

    try:
        face_objs = DeepFace.extract_faces(img_path=temp_uploaded_path, anti_spoofing=True)

        # If any face is spoofed, throw an exception
        if not all(face_obj["is_real"] for face_obj in face_objs):
            # Clean up temporary files before raising an error
            os.remove(temp_uploaded_path)
            os.remove(temp_stored_path)
            raise HTTPException(
                status_code=400, detail="Spoofed image detected! Attendance not marked."
            )

    except Exception as e:
        # Clean up temporary files before raising an error
        os.remove(temp_uploaded_path)
        os.remove(temp_stored_path)
        raise HTTPException(
            status_code=500, detail=f"Error during anti-spoofing check: {e}"
        )
    
    # Step 4: Perform face verification
    try:
        result = DeepFace.verify(
            img1_path=temp_uploaded_path,
            img2_path=temp_stored_path,
            model_name="Facenet512"
            
        )
    except Exception as e:
        # Clean up temporary files before raising an error
        os.remove(temp_uploaded_path)
        os.remove(temp_stored_path)
        raise HTTPException(
            status_code=500, detail=f"Error during face verification: {e}"
        )

    # Clean up temporary files
    os.remove(temp_uploaded_path)
    os.remove(temp_stored_path)

    if not result["verified"]:
        raise HTTPException(
            status_code=401, detail="Face recognition failed. Unauthorized."
        )

    # Step 5: Mark attendance
    current_time = datetime.now()
    today_date = current_time.date()

    # Check if there is an attendance record for the faculty for today
    attendance_record = (
        db.query(Attendance)
        .filter(Attendance.faculty_id == faculty_id)
        .filter(Attendance.date == today_date)
        .first()
    )

    if attendance_record:
        # if attendance_record.status== "Present":
        #     # Update the record with logout time
        #     attendance_record.logout_time = current_time
        #     attendance_record.status = "Absent"
        attendance_record.logout_time = current_time
        attendance_record.status = "present"
        # else:
        #     raise HTTPException(
        #         status_code=400, detail="Attendance already marked as Logout."
        #     )
    else:
        # Create a new attendance record for Login
        attendance_record = Attendance(
            faculty_id=faculty_id,
            status="Present",
            login_time=current_time,
            logout_time=None,
            date=today_date,
        )
        db.add(attendance_record)

    # Save changes to the database
    db.commit()
    db.refresh(attendance_record)

    return {
        "message": "Attendance marked successfully",
        "faculty_id": faculty_id,
        "faculty_name": faculty.name,
        "status":attendance_record.status,
        "date": str(today_date),
        "time": str(current_time),
    }

###---------- Update Image

@app.post("/api/update-image/")
async def update_image(faculty_id: str = Form(...), image: UploadFile = File(...), db: Session = Depends(get_db)):
    update = db.query(Faculty).filter(Faculty.faculty_id == faculty_id).first()

    # Check if the faculty exists
    if not update:
        raise HTTPException(
            status_code=404, detail=f"No faculty found with ID: {faculty_id}"
        )

    # Save the uploaded image to a temporary location
    try:
        image_path = f"uploads/{image.filename}"
        async with aiofiles.open(image_path, "wb") as out_file:
            content = await image.read()
            await out_file.write(content)

        # Optional: Anti-spoofing check (can be added here)

        # Update the faculty's image in the database (as binary or path)
        update.image = content  # You can also store the path here instead of the binary
        db.commit()

        return JSONResponse(content={"message": "Image updated successfully"}, status_code=200)
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error updating image: {str(e)}"
        )
    finally:
        db.close()

### Get Image

@app.get("/get-image/")

async def get_image(faculty_id: str):
    db = SessionLocal()
    faculty = db.query(Faculty).filter(Faculty.faculty_id == faculty_id).first()
    if not faculty:
        raise HTTPException(
            status_code=404, detail=f"No faculty found with ID: {faculty_id}"
        )
    if not faculty.image:
        raise HTTPException(
            status_code=400, detail=f"No image found for faculty ID: {faculty_id}"
        )
    return Response(content=faculty.image, media_type="image/jpeg")