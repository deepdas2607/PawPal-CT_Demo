"""
Care Reminders REST API Routes.
Handles scheduling, completing, updating, and deleting pet care reminders in SQLite.
"""

from fastapi import APIRouter, Depends, HTTPException, status
import sqlite3
import uuid
from datetime import datetime, timezone
from typing import List

from .database import get_db
from .schemas import ReminderCreate, ReminderUpdate, ReminderResponse
from .models import row_to_reminder_dict

router = APIRouter(tags=["Reminders"])

@router.get("/api/pets/{pet_id}/reminders", response_model=List[ReminderResponse])
def list_reminders(pet_id: str, db: sqlite3.Connection = Depends(get_db)):
    """
    Fetch all care reminders for a specific pet.
    Sorted by due date ascending (earliest upcoming reminders first).
    """
    cursor = db.cursor()
    # Check if pet exists
    cursor.execute("SELECT id FROM pets WHERE id = ?;", (pet_id,))
    if not cursor.fetchone():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Pet with ID '{pet_id}' was not found."
        )

    cursor.execute("""
        SELECT * FROM care_reminders
        WHERE pet_id = ?
        ORDER BY is_completed ASC, due_date ASC;
    """, (pet_id,))
    rows = cursor.fetchall()
    return [row_to_reminder_dict(r) for r in rows]

@router.post("/api/pets/{pet_id}/reminders", response_model=ReminderResponse, status_code=status.HTTP_201_CREATED)
def create_reminder(pet_id: str, reminder_data: ReminderCreate, db: sqlite3.Connection = Depends(get_db)):
    """
    Create a new care reminder for a pet.
    Saves to SQLite with default is_completed = 0 (false).
    """
    cursor = db.cursor()
    # Check if pet exists
    cursor.execute("SELECT id FROM pets WHERE id = ?;", (pet_id,))
    if not cursor.fetchone():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Pet with ID '{pet_id}' was not found."
        )

    reminder_id = str(uuid.uuid4())
    now_iso = datetime.now(timezone.utc).isoformat()

    cursor.execute("""
        INSERT INTO care_reminders (id, pet_id, title, notes, due_date, is_completed, created_at)
        VALUES (?, ?, ?, ?, ?, 0, ?);
    """, (
        reminder_id,
        pet_id,
        reminder_data.title.strip(),
        reminder_data.notes.strip() if reminder_data.notes else None,
        reminder_data.due_date,
        now_iso
    ))
    db.commit()

    cursor.execute("SELECT * FROM care_reminders WHERE id = ?;", (reminder_id,))
    row = cursor.fetchone()
    return row_to_reminder_dict(row)

@router.patch("/api/reminders/{reminder_id}", response_model=ReminderResponse)
def update_reminder(reminder_id: str, reminder_data: ReminderUpdate, db: sqlite3.Connection = Depends(get_db)):
    """
    Update a reminder's completion state, title, notes, or due date.
    Sets completed_at timestamp automatically when marked completed.
    """
    cursor = db.cursor()
    cursor.execute("SELECT * FROM care_reminders WHERE id = ?;", (reminder_id,))
    existing = cursor.fetchone()
    if not existing:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Reminder with ID '{reminder_id}' was not found."
        )

    new_title = reminder_data.title.strip() if reminder_data.title is not None else existing["title"]
    new_notes = reminder_data.notes.strip() if reminder_data.notes is not None else existing["notes"]
    new_due_date = reminder_data.due_date if reminder_data.due_date is not None else existing["due_date"]
    
    if reminder_data.is_completed is not None:
        new_is_completed = 1 if reminder_data.is_completed else 0
        now_iso = datetime.now(timezone.utc).isoformat()
        new_completed_at = now_iso if reminder_data.is_completed else None
    else:
        new_is_completed = existing["is_completed"]
        new_completed_at = existing["completed_at"]

    cursor.execute("""
        UPDATE care_reminders
        SET title = ?, notes = ?, due_date = ?, is_completed = ?, completed_at = ?
        WHERE id = ?;
    """, (new_title, new_notes, new_due_date, new_is_completed, new_completed_at, reminder_id))
    db.commit()

    cursor.execute("SELECT * FROM care_reminders WHERE id = ?;", (reminder_id,))
    updated_row = cursor.fetchone()
    return row_to_reminder_dict(updated_row)

@router.delete("/api/reminders/{reminder_id}", status_code=status.HTTP_200_OK)
def delete_reminder(reminder_id: str, db: sqlite3.Connection = Depends(get_db)):
    """
    Delete a reminder from SQLite by its ID.
    """
    cursor = db.cursor()
    cursor.execute("SELECT id FROM care_reminders WHERE id = ?;", (reminder_id,))
    if not cursor.fetchone():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Reminder with ID '{reminder_id}' was not found."
        )

    cursor.execute("DELETE FROM care_reminders WHERE id = ?;", (reminder_id,))
    db.commit()
    return {"message": "Reminder deleted successfully", "id": reminder_id}

