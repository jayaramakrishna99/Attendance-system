from fastapi import APIRouter, Depends, HTTPException, Form, Request # type: ignore
from sqlalchemy.orm import Session # type: ignore
from models import Employee,Attendance
from database import get_db
from Cryptodome.Cipher import AES # type: ignore
from Cryptodome.Util.Padding import pad, unpad  # type: ignore

import base64

router = APIRouter()

AES_KEY ="1234567891234567"  # 16-byte key
AES_IV = "1234567891234567"  # 16-byte IV

if len(AES_KEY) != 16 or len(AES_IV) != 16:
    raise ValueError("AES_KEY and AES_IV must be exactly 16 bytes long")

# Convert to bytes
key = AES_KEY.encode()
iv = AES_IV.encode()

#  Encrypt Function (AES-CBC + Base64)
def encrypt(data: str) -> str:
    cipher = AES.new(key, AES.MODE_CBC, iv)
    padded_data = pad(data.encode(), AES.block_size)
    encrypted_bytes = cipher.encrypt(padded_data)
    return base64.b64encode(encrypted_bytes).decode()  

#  Decrypt Function
def decrypt(encrypted_data: str) -> str:
    cipher = AES.new(key, AES.MODE_CBC, iv)
    encrypted_bytes = base64.b64decode(encrypted_data) 
    decrypted_padded = cipher.decrypt(encrypted_bytes)
    return unpad(decrypted_padded, AES.block_size).decode()

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
    
    encrypted_password = encrypt(password) 
    new_employee = Employee(employee_id=employee_id, name=name, password=encrypted_password)
    db.add(new_employee)
    db.commit()
    return {"message": "Employee added successfully"}


@router.get("/get-employee-details/")
async def get_employee_details(employee_id: str, db: Session = Depends(get_db)):
    db_employee = db.query(Employee).filter(Employee.employee_id == employee_id).first()

    if not db_employee:
        raise HTTPException(status_code=404, detail="Employee not found")

    decrypted_password = decrypt(db_employee.password)

    return {
        "name": db_employee.name,
        "password": decrypted_password 
    }


@router.post("/login/")
async def login_employee(request: Request, db: Session = Depends(get_db)):
    data = await request.json()
    employee_id = data.get("employee_id")
    password = data.get("password")

    db_employee = db.query(Employee).filter(Employee.employee_id == employee_id).first()
    encrypted_password = encrypt(password) 
    if not db_employee or db_employee.password != encrypted_password:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    return {"message": "Login successful"}


# @router.get("/view-attendance/")
# async def view_attendance(employee_id: str, db: Session = Depends(get_db)):
#     db_employee = db.query(Attendance).filter(Attendance.faculty_id == employee_id).first()
#     if not db_employee:
#         raise HTTPException(status_code=404, detail="Employee not found")
#     return {"name": db_employee.faculty_id, "employee_id": db_employee.employee_id}