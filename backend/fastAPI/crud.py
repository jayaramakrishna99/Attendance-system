from sqlalchemy.orm import Session # type: ignore
from models import Employee, Faculty, Attendance

def create_employee(db: Session, employee_id: str, name: str, password: str):
    new_employee = Employee(employee_id=employee_id, name=name, password=password)
    db.add(new_employee)
    db.commit()
    db.refresh(new_employee)
    return new_employee

def get_employee(db: Session, employee_id: str):
    return db.query(Employee).filter(Employee.employee_id == employee_id).first()
