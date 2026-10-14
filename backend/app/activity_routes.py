"""
Care Activities REST API Routes.
Handles logging daily care actions (walking, feeding, meds, grooming) for a pet.
"""

from fastapi import APIRouter, Depends, HTTPException, status
import sqlite3
import uuid
from datetime import datetime, timezone
from typing import List

from .database import get_db
from .schemas import ActivityCreate, ActivityResponse
from .models import row_to_activity_dict

router = APIRouter(prefix="/api/pets/{pet_id}/activities", tags=["Activities"])

@router.get("", response_model=List[ActivityResponse])
def list_activities(pet_id: str, db: sqlite3.Connection = Depends(get_db)):
    """
    Fetch all care activities logged for a given pet.
    Sorted chronologically with newest activities first.
    """
    cursor = db.cursor()
    # Confirm pet exists
    cursor.execute("SELECT id FROM pets WHERE id = ?;", (pet_id,))
    if not cursor.fetchone():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Pet with ID '{pet_id}' was not found."
        )

    cursor.execute("""
        SELECT * FROM care_activities
        WHERE pet_id = ?
        ORDER BY timestamp DESC;
    """, (pet_id,))
    rows = cursor.fetchall()
    return [row_to_activity_dict(r) for r in rows]

@router.post("", response_model=ActivityResponse, status_code=status.HTTP_201_CREATED)
def create_activity(pet_id: str, activity_data: ActivityCreate, db: sqlite3.Connection = Depends(get_db)):
    """
    Log a new care activity for a pet and save it to SQLite.
    Validates that the referenced pet exists before insertion.
    """
    cursor = db.cursor()
    # Confirm pet exists
    cursor.execute("SELECT id FROM pets WHERE id = ?;", (pet_id,))
    if not cursor.fetchone():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Pet with ID '{pet_id}' was not found."
        )

    activity_id = str(uuid.uuid4())
    now_iso = datetime.now(timezone.utc).isoformat()

    cursor.execute("""
        INSERT INTO care_activities (id, pet_id, activity_type, timestamp, duration_minutes, notes, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?);
    """, (
        activity_id,
        pet_id,
        activity_data.activity_type.strip(),
        activity_data.timestamp,
        activity_data.duration_minutes,
        activity_data.notes.strip() if activity_data.notes else None,
        now_iso
    ))
    db.commit()

    cursor.execute("SELECT * FROM care_activities WHERE id = ?;", (activity_id,))
    row = cursor.fetchone()
    return row_to_activity_dict(row)

