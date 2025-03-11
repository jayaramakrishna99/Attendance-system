# from fastapi import APIRouter, Depends, HTTPException, Form #type: ignore
# from sqlalchemy.orm import Session #type: ignore
# from database import get_db
# from models import Location, Employee 
# from fastapi.responses import JSONResponse #type: ignore

# router = APIRouter()

# @router.post("/location/")
# def update_location(
#     employee_id: str = Form(...),
#     latitude: float = Form(...),
#     longitude: float = Form(...),
#     db: Session = Depends(get_db)
# ):
#     # Validate if employee exists
#     employee = db.query(Employee).filter(Employee.employee_id == employee_id).first()

#     if not employee:
#         raise HTTPException(status_code=404, detail="Employee not found")

#     # Check if location record exists
#     location = db.query(Location).filter(Location.employee_id == employee_id).first()

#     if location:
#         # Update location if already exists
#         location.latitude = latitude
#         location.longitude = longitude
#     else:
#         # Create a new location record
#         location = Location(
#             employee_id=employee_id,
#             latitude=latitude,
#             longitude=longitude
#         )
#         db.add(location)

#     db.commit()
#     db.refresh(location)

#     return JSONResponse(content={
#         "message": "Location updated successfully",
#         "employee_id": employee_id,
#         "latitude": latitude,
#         "longitude": longitude
#     })

from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from database import get_db
from models import Employee, Location  # Assuming you have these models

router = APIRouter()

@router.post("/location/")
async def update_location(
    payload: dict = Body(...), 
    db: Session = Depends(get_db)
):
    # Extract values from the payload dictionary
    employee_id = payload.get("employee_id")
    latitude = payload.get("latitude")
    longitude = payload.get("longitude")

    if not employee_id or latitude is None or longitude is None:
        raise HTTPException(status_code=400, detail="Missing employee_id, latitude, or longitude")

    # Check if employee exists
    employee = db.query(Employee).filter(Employee.employee_id == employee_id).first()

    if not employee:
        raise HTTPException(status_code=404, detail=f"No employee found with ID: {employee_id}")

    # Check if there is already a location record for this employee
    location_record = db.query(Location).filter(Location.employee_id == employee_id).first()

    if location_record:
        location_record.latitude = latitude
        location_record.longitude = longitude
    else:
        location_record = Location(
            employee_id=employee_id,
            latitude=latitude,
            longitude=longitude
        )
        db.add(location_record)

    db.commit()

    return {"message": "Location updated successfully!"}
