"""
Pet Care Tips REST API Routes.
Handles fetching seeded pet wellness tips and saving/unsaving favorites per pet.
"""

from fastapi import APIRouter, Depends, HTTPException, status
import sqlite3
from datetime import datetime, timezone
from typing import List

from .database import get_db
from .schemas import TipResponse
from .models import row_to_tip_dict

router = APIRouter(tags=["Tips"])

@router.get("/api/tips", response_model=List[TipResponse])
def list_tips(db: sqlite3.Connection = Depends(get_db)):
    """
    Fetch all pet care tips available in the database.
    """
    cursor = db.cursor()
    cursor.execute("SELECT * FROM pet_tips ORDER BY id ASC;")
    rows = cursor.fetchall()
    return [row_to_tip_dict(r, is_saved=False) for r in rows]

@router.get("/api/pets/{pet_id}/saved-tips", response_model=List[str])
def list_saved_tips(pet_id: str, db: sqlite3.Connection = Depends(get_db)):
    """
    Fetch the list of tip IDs saved/favorited by the specified pet.
    """
    cursor = db.cursor()
    # Confirm pet exists
    cursor.execute("SELECT id FROM pets WHERE id = ?;", (pet_id,))
    if not cursor.fetchone():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Pet with ID '{pet_id}' was not found."
        )

    cursor.execute("SELECT tip_id FROM saved_tips WHERE pet_id = ?;", (pet_id,))
    rows = cursor.fetchall()
    return [r["tip_id"] for r in rows]

@router.put("/api/pets/{pet_id}/saved-tips/{tip_id}", status_code=status.HTTP_200_OK)
def save_tip(pet_id: str, tip_id: str, db: sqlite3.Connection = Depends(get_db)):
    """
    Save a tip as favorite for a pet profile.
    Idempotent: saving an already saved tip succeeds without duplicate entries.
    """
    cursor = db.cursor()
    # Check pet exists
    cursor.execute("SELECT id FROM pets WHERE id = ?;", (pet_id,))
    if not cursor.fetchone():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Pet with ID '{pet_id}' was not found."
        )

    # Check tip exists
    cursor.execute("SELECT id FROM pet_tips WHERE id = ?;", (tip_id,))
    if not cursor.fetchone():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Tip with ID '{tip_id}' was not found."
        )

    now_iso = datetime.now(timezone.utc).isoformat()
    cursor.execute("""
        INSERT OR IGNORE INTO saved_tips (pet_id, tip_id, saved_at)
        VALUES (?, ?, ?);
    """, (pet_id, tip_id, now_iso))
    db.commit()

    return {"message": "Tip saved successfully", "pet_id": pet_id, "tip_id": tip_id}

@router.delete("/api/pets/{pet_id}/saved-tips/{tip_id}", status_code=status.HTTP_200_OK)
def unsave_tip(pet_id: str, tip_id: str, db: sqlite3.Connection = Depends(get_db)):
    """
    Remove a tip from a pet's saved favorites.
    """
    cursor = db.cursor()
    cursor.execute("""
        DELETE FROM saved_tips
        WHERE pet_id = ? AND tip_id = ?;
    """, (pet_id, tip_id))
    db.commit()

    return {"message": "Tip unsaved successfully", "pet_id": pet_id, "tip_id": tip_id}

