from fastapi import FastAPI # type: ignore
from fastapi.middleware.cors import CORSMiddleware # type: ignore
from routers import faculty, attendance, employee
from database import engine, Base
import os

# Create tables in the database
Base.metadata.create_all(bind=engine)

# Check environment variable
is_production = os.getenv("ENV") == "production"

# Initialize FastAPI app (disable Swagger in production)
app = FastAPI(docs_url=None, redoc_url=None) if is_production else FastAPI()

# # Initialize FastAPI app
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

