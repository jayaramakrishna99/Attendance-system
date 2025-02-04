from fastapi import APIRouter, Depends, HTTPException, UploadFile, Form, Response, File
from sqlalchemy.orm import Session
import aiofiles
from models import Faculty
from database import get_db
from fastapi.responses import JSONResponse
from deepface import DeepFace



router = APIRouter()

@router.post("/register/")
async def submit_data(
    id: str = Form(...),
    name: str = Form(...),
    image: UploadFile = None,
    db: Session = Depends(get_db)
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
# async def update_image(
#     faculty_id: str = Form(...),
#     image: UploadFile = File(...),
#     db: Session = Depends(get_db)
# ):
#     update = db.query(Faculty).filter(Faculty.faculty_id == faculty_id).first()

#     if not update:
#         raise HTTPException(status_code=404, detail="Faculty not found")

#     try:
#         async with aiofiles.open(f"uploads/{image.filename}", "wb") as out_file:
#             content = await image.read()
#             await out_file.write(content)

#         update.image = content
#         db.commit()

#         return {"message": "Image updated successfully"}
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=f"Error updating image: {str(e)}")
    


@router.get("/get-image/")
async def get_image(faculty_id: str, db: Session = Depends(get_db)):
    faculty = db.query(Faculty).filter(Faculty.faculty_id == faculty_id).first()

    if not faculty:
        raise HTTPException(status_code=404, detail="Faculty not found")
    
    if not faculty.image:
        raise HTTPException(status_code=400, detail="No image available for this faculty")

    return Response(content=faculty.image, media_type="image/jpeg")