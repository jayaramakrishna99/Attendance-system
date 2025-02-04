from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import faculty, attendance, employee
from database import engine, Base

# Create tables in the database
Base.metadata.create_all(bind=engine)

# Initialize FastAPI app
app = FastAPI()

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
