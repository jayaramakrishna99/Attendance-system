from fastapi import APIRouter, Depends, HTTPException, UploadFile, Form, Response, File
from sqlalchemy.orm import Session
import aiofiles
from models import Faculty
from database import get_db
from fastapi.responses import JSONResponse




router = APIRouter()

@router.post("/register/")
async def submit_data(
    id: str = Form(...),
    name: str = Form(...),
    image: UploadFile = None,
    db: Session = Depends(get_db)
):
    try:
        existing_faculty = db.query(Faculty).filter(Faculty.faculty_id == id).first()
        if existing_faculty:
            return JSONResponse(content={ "Message":"Faculty already registered"}, status_code=400)
        async with aiofiles.open(f"uploads/{image.filename}", "wb") as out_file:
            content = await image.read()
            await out_file.write(content)

        faculty = Faculty(faculty_id=id, name=name, image=content)
        db.add(faculty)
        db.commit()
        db.close()

        return JSONResponse(content={"message": "Faculty registered successfully"}, status_code=200)
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

@router.post("/update-image/")
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

        update.image = content  # You can also store the path here instead of the binary
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