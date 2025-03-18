from fastapi import APIRouter, Depends, HTTPException, Body #type: ignore
from sqlalchemy.orm import Session #type: ignore
from sqlalchemy.sql import func #type: ignore
from database import get_db
from datetime import date, datetime
from models import Employee, Location, Attendance 

router = APIRouter()

@router.post("/location/")
async def update_location(
    payload: dict = Body(...), 
    db: Session = Depends(get_db)
):
    employee_id = payload.get("employee_id")
    latitude = payload.get("latitude")
    longitude = payload.get("longitude")

    if not employee_id or latitude is None or longitude is None:
        raise HTTPException(status_code=400, detail="Missing employee_id, latitude, or longitude")

    # Check if employee exists
    employee = db.query(Employee).filter(Employee.employee_id == employee_id).first()

    if not employee:
        raise HTTPException(status_code=404, detail=f"No employee found with ID: {employee_id}")

    today_date = date.today()

    location_record = db.query(Location).filter(
        Location.employee_id == employee_id,
        func.date(Location.updated_at) == today_date
    ).first()

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



@router.get("/employee-locations/")
def get_employee_locations(db: Session = Depends(get_db)):
    today = date.today()

    attended_employee_ids = db.query(Attendance.faculty_id).filter(
        Attendance.date == today
    ).distinct().all()

    employee_ids = [emp_id for (emp_id,) in attended_employee_ids]

    locations = (
    db.query(Location, Employee)
    .join(Employee, Employee.employee_id == Location.employee_id)
    .filter(
        Location.employee_id.in_(employee_ids),
        func.date(Location.updated_at) == today  
    )
    .all()
    )

    result = []
    for loc, emp in locations:
        result.append({
            "employee_id": emp.employee_id,
            "name": emp.name,
            "latitude": loc.latitude,
            "longitude": loc.longitude,
            "timestamp": loc.updated_at.isoformat() 
        })

    return result

@router.get("/employee-locations/by-employee-id/{employee_id}")
def get_locations_by_employee_id(employee_id: str, db: Session = Depends(get_db)):
    locations = (
        db.query(Location, Employee)
        .join(Employee, Employee.employee_id == Location.employee_id)
        .filter(Location.employee_id == employee_id)
        .order_by(Location.updated_at.desc())
        .all()
    )

    if not locations:
        raise HTTPException(status_code=404, detail="No locations found for this employee.")

    result = []
    for loc, emp in locations:
        result.append({
            "employee_id": emp.employee_id,
            "name": emp.name,
            "latitude": loc.latitude,
            "longitude": loc.longitude,
            "updated_at": loc.updated_at
        })

    return result



@router.get("/employee-locations/by-date/{date_str}")
def get_locations_by_date(date_str: str, db: Session = Depends(get_db)):
    date_str = date_str[:10]
    print(date_str)
    try:
        date_obj = datetime.strptime(date_str, "%Y-%m-%d").date()
        print(date_obj)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD")

    locations = (
        db.query(Location, Employee)
        .join(Employee, Employee.employee_id == Location.employee_id)
        .filter(func.date(Location.updated_at) == date_obj)
        .order_by(Location.updated_at.desc())
        .all()
    )

    if not locations:
        raise HTTPException(status_code=404, detail="No locations found for this date.")

    result = []
    for loc, emp in locations:
        result.append({
            "employee_id": emp.employee_id,
            "name": emp.name,
            "latitude": loc.latitude,
            "longitude": loc.longitude,
            "updated_at": loc.updated_at
        })

    return result
