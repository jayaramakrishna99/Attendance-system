# from fastapi import FastAPI # type: ignore
# from fastapi.middleware.cors import CORSMiddleware # type: ignore
# from routers import faculty, attendance, employee
# from database import engine, Base
# import os
# from routers import location


# # Create tables in the database
# Base.metadata.create_all(bind=engine)

# # Check environment variable
# is_production = os.getenv("ENV") == "production"

# # Initialize FastAPI app (disable Swagger in production)
# app = FastAPI(docs_url=None, redoc_url=None) if is_production else FastAPI()

# # # Initialize FastAPI app
# # app = FastAPI()

# # CORS Middleware
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# # Include Routers
# app.include_router(faculty.router, prefix="/api")
# app.include_router(attendance.router, prefix="/api")
# app.include_router(employee.router, prefix="/api")
# app.include_router(location.router,prefix="/api")


from fastapi import FastAPI  # type: ignore
from fastapi.middleware.cors import CORSMiddleware  # type: ignore
from routers import faculty, attendance, employee, location
from database import engine, Base, SessionLocal
import os
from models import Attendance
from datetime import datetime, time
from apscheduler.schedulers.background import BackgroundScheduler
import atexit

# Create tables in the database
Base.metadata.create_all(bind=engine)

# Check environment variable
is_production = os.getenv("ENV") == "production"

# Initialize FastAPI app (disable Swagger in production)
app = FastAPI(docs_url=None, redoc_url=None) if is_production else FastAPI()

# app = FastAPI()

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(faculty.router, prefix="/api")
app.include_router(attendance.router, prefix="/api")
app.include_router(employee.router, prefix="/api")
app.include_router(location.router, prefix="/api")

# Function to update attendance status
def update_attendance_status():
    db = SessionLocal()
    try:
        today = datetime.now().date()
        attendances = db.query(Attendance).filter(Attendance.date == today).all()

        for record in attendances:
            if record.login_time and record.logout_time:
                login_time = datetime.strptime(record.login_time, "%H:%M:%S").time()
                logout_time = datetime.strptime(record.logout_time, "%H:%M:%S").time()

                if login_time <= time(8, 5) and logout_time >= time(16, 0):
                    record.status = "Present"
                else:
                    record.status = "Absent"
            else:
                record.status = "Absent"  

        db.commit()
        print("Attendance status updated successfully.")
    except Exception as e:
        print(f"Error updating attendance: {e}")
    finally:
        db.close()

# Initialize scheduler
scheduler = BackgroundScheduler()
scheduler.add_job(update_attendance_status, "cron", hour=12, minute=9)  
scheduler.start()

# Shutdown scheduler on exit
atexit.register(lambda: scheduler.shutdown())
