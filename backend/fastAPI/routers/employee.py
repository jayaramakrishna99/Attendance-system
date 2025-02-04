from fastapi import APIRouter, Depends, HTTPException, Form, Request
from sqlalchemy.orm import Session
from models import Employee
from database import get_db

router = APIRouter()

@router.post("/add-employee/")
async def add_employee(
    employee_id: str = Form(...),
    name: str = Form(...),
    password: str = Form(...),
    db: Session = Depends(get_db)
):
    db_employee = db.query(Employee).filter(Employee.employee_id == employee_id).first()
    if db_employee:
        raise HTTPException(status_code=400, detail="Employee ID already exists")

    new_employee = Employee(employee_id=employee_id, name=name, password=password)
    db.add(new_employee)
    db.commit()
    return {"message": "Employee added successfully"}


@router.get("/get-employee-details/")
async def get_employee_details(employee_id: str, db: Session = Depends(get_db)):
    db_employee = db.query(Employee).filter(Employee.employee_id == employee_id).first()

    if not db_employee:
        raise HTTPException(status_code=404, detail="Employee not found")

    return {
        "name": db_employee.name,
        "password": db_employee.password  # ⚠️ Consider encrypting passwords for security
    }


@router.post("/login/")
async def login_employee(request: Request, db: Session = Depends(get_db)):
    data = await request.json()
    employee_id = data.get("employee_id")
    password = data.get("password")

    db_employee = db.query(Employee).filter(Employee.employee_id == employee_id).first()
    if not db_employee or db_employee.password != password:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    return {"message": "Login successful"}




# @router.post("/login/")
# async def login_employee(request: Request, db: Session = Depends(get_db)):
#     data = await request.json()  # Parse JSON request

#     employee_id = data.get("employee_id")
#     password = data.get("password")

#     if not employee_id or not password:
#         raise HTTPException(status_code=400, detail="Employee ID and Password are required")

#     # Check if the employee exists
#     db_employee = db.query(Employee).filter(Employee.employee_id == employee_id).first()
#     if not db_employee:
#         raise HTTPException(status_code=404, detail="Employee not found")

#     # Validate password (consider hashing in production)
#     if db_employee.password != password:
#         raise HTTPException(status_code=401, detail="Invalid credentials")

#     return {"message": "Login successful"}