"""
Main FastAPI Application for PawPal.
Initializes the REST API, configures CORS, sets up database tables, and registers routes.
"""

from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import sqlite3

from .database import initialize_database, get_db
from .schemas import HealthResponse
from .pet_routes import router as pet_router
from .activity_routes import router as activity_router
from .reminder_routes import router as reminder_router
from .tips_routes import router as tips_router

@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Lifespan context manager that runs when the FastAPI server starts up.
    Initializes SQLite tables and seeds default pet care tips.
    """
    # 1. Setup SQLite database tables & seed tips
    initialize_database()
    yield
    # Code below yield runs on shutdown (if cleanup needed)

# Initialize FastAPI application
app = FastAPI(
    title="PawPal API",
    description="REST backend for the PawPal iOS pet-care companion application.",
    version="1.0.0",
    lifespan=lifespan
)

# Configure Cross-Origin Resource Sharing (CORS) for development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Health Check Endpoint
@app.get("/health", response_model=HealthResponse, tags=["Health"])
@app.get("/api/health", response_model=HealthResponse, tags=["Health"])
def health_check(db: sqlite3.Connection = Depends(get_db)):
    """
    Checks that the server is alive and that the SQLite database is reachable.
    """
    # Simple query to verify SQLite connection
    cursor = db.cursor()
    cursor.execute("SELECT 1;")
    cursor.fetchone()
    
    return {
        "status": "ok",
        "database": "connected",
        "version": "1.0.0"
    }

# Register Feature Routers
app.include_router(pet_router)
app.include_router(activity_router)
app.include_router(reminder_router)
app.include_router(tips_router)

