"""
Pydantic Data Schemas for PawPal REST API.
Validates client request payloads and defines standard response structures.
"""

from pydantic import BaseModel, Field
from typing import Optional, List

# --- Pet Profile Schemas ---

class PetCreate(BaseModel):
    """Schema used when the user creates a new pet profile."""
    name: str = Field(..., min_length=1, max_length=50, description="Pet name (required)")
    species: str = Field(..., min_length=1, max_length=30, description="Pet species e.g. Dog, Cat, Bird")
    breed: Optional[str] = Field(None, max_length=50, description="Optional breed")
    date_of_birth: Optional[str] = Field(None, description="Optional birthdate (YYYY-MM-DD)")
    avatar_symbol: Optional[str] = Field("pawprint.fill", description="SF Symbol name for avatar")

class PetUpdate(BaseModel):
    """Schema used when updating an existing pet profile."""
    name: Optional[str] = Field(None, min_length=1, max_length=50)
    species: Optional[str] = Field(None, min_length=1, max_length=30)
    breed: Optional[str] = None
    date_of_birth: Optional[str] = None
    avatar_symbol: Optional[str] = None

class PetResponse(BaseModel):
    """Standard response model for a pet profile."""
    id: str
    name: str
    species: str
    breed: Optional[str] = None
    date_of_birth: Optional[str] = None
    avatar_symbol: str
    created_at: str
    updated_at: str

# --- Care Activity Schemas ---

class ActivityCreate(BaseModel):
    """Schema for logging a care activity (e.g. Walking, Feeding)."""
    activity_type: str = Field(..., min_length=1, description="Walking, Feeding, Grooming, Medication, Vet Visit, Playtime, Other")
    timestamp: str = Field(..., description="ISO 8601 formatted timestamp")
    duration_minutes: Optional[int] = Field(None, ge=0, description="Optional duration in minutes")
    notes: Optional[str] = Field(None, max_length=500, description="Optional care notes")

class ActivityResponse(BaseModel):
    """Response model for a care activity record."""
    id: str
    pet_id: str
    activity_type: str
    timestamp: str
    duration_minutes: Optional[int] = None
    notes: Optional[str] = None
    created_at: str

# --- Care Reminder Schemas ---

class ReminderCreate(BaseModel):
    """Schema for scheduling a new care reminder."""
    title: str = Field(..., min_length=1, max_length=100, description="Reminder title e.g. Evening walk")
    notes: Optional[str] = Field(None, max_length=500, description="Optional notes")
    due_date: str = Field(..., description="ISO 8601 formatted due date and time")

class ReminderUpdate(BaseModel):
    """Schema for updating an existing reminder status."""
    title: Optional[str] = None
    notes: Optional[str] = None
    due_date: Optional[str] = None
    is_completed: Optional[bool] = None

class ReminderResponse(BaseModel):
    """Response model for a care reminder."""
    id: str
    pet_id: str
    title: str
    notes: Optional[str] = None
    due_date: str
    is_completed: bool
    completed_at: Optional[str] = None
    created_at: str

# --- Pet Care Tips Schemas ---

class TipResponse(BaseModel):
    """Response model for a pet care tip."""
    id: str
    title: str
    content: str
    category: str
    icon_name: str
    is_saved: bool = False

# --- Health Check Schema ---

class HealthResponse(BaseModel):
    """Response model for server health check."""
    status: str
    database: str
    version: str

