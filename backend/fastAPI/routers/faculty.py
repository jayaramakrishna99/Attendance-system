from fastapi import APIRouter, Depends, HTTPException, UploadFile, Form, Response, File # type: ignore
from sqlalchemy.orm import Session # type: ignore
import aiofiles # type: ignore
from models import Faculty
from database import get_db
from fastapi.responses import JSONResponse # type: ignore
from tempfile import NamedTemporaryFile
from .antispoofing import predict_spoof
import os
import base64

router = APIRouter()

@router.post("/register/")
async def submit_data(
    id: str = Form(...),
    name: str = Form(...),
    image: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    try:
        existing_faculty = db.query(Faculty).filter(Faculty.faculty_id == id).first()
        if existing_faculty:
            return JSONResponse(content={"Message": "Faculty already registered"}, status_code=400)

        content = await image.read()

        # Save Temporary Image File
        temp_uploaded_path = None
        try:
            with NamedTemporaryFile(delete=False, suffix=".jpg") as temp_uploaded:
                temp_uploaded.write(content)
                temp_uploaded_path = temp_uploaded.name

            # Anti-Spoofing Check
            if not predict_spoof(temp_uploaded_path):
                os.remove(temp_uploaded_path)
                return JSONResponse(content={"Message": "Spoofed Image Detected"}, status_code=401)

        finally:
            if temp_uploaded_path and os.path.exists(temp_uploaded_path):
                os.remove(temp_uploaded_path)

        # Save Faculty Data in Database
        faculty = Faculty(faculty_id=id, name=name, image=content)
        db.add(faculty)
        db.commit()
        db.close()

        return JSONResponse(content={"Message": "Faculty registered successfully"}, status_code=200)

    except Exception as e:
        return JSONResponse(content={"Error": str(e)}, status_code=500)

@router.post("/update-image/")
async def update_image(faculty_id: str = Form(...), image: UploadFile = File(...), db: Session = Depends(get_db)):
    update = db.query(Faculty).filter(Faculty.faculty_id == faculty_id).first()

    # Check if the faculty exists
    if not update:
        return JSONResponse(content={"Error": str(faculty_id)}, status_code=404)

    # Save the uploaded image to a temporary location
    try:
        image_path = f"uploads/{image.filename}"
        async with aiofiles.open(image_path, "wb") as out_file:
            content = await image.read()
            await out_file.write(content)

        update.image = content  
        db.commit()

        return JSONResponse(content={"message": "Image updated successfully"}, status_code=200)
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error updating image: {str(e)}"
        )
    finally:
        db.close()
    


@router.get("/get-image/")
async def get_image(faculty_id: str, db: Session = Depends(get_db)):
    faculty = db.query(Faculty).filter(Faculty.faculty_id == faculty_id).first()

    if not faculty:
        raise HTTPException(status_code=404, detail="Faculty not found")
    
    if not faculty.image:
        raise HTTPException(status_code=400, detail="No image available for this faculty")

    return Response(content=faculty.image, media_type="image/jpeg")

@router.get("/get_faculty_image/{faculty_id}")
def get_faculty_image(faculty_id: str, db: Session = Depends(get_db)):
    faculty = db.query(Faculty).filter(Faculty.faculty_id == faculty_id).first()
    
    if not faculty or not faculty.image:
        raise HTTPException(status_code=404, detail="Faculty image not found")

    # Encode the image to Base64
    encoded_image = base64.b64encode(faculty.image).decode('utf-8')

    return {
        "faculty_id": faculty_id,
        "name": faculty.name,   # Include faculty name
        "image_base64": encoded_image
    }
