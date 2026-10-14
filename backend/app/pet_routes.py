"""
Pet Profile REST API Routes.
Handles creating, retrieving, and updating pet profiles in SQLite.
"""

from fastapi import APIRouter, Depends, HTTPException, status
import sqlite3
import uuid
from datetime import datetime, timezone
from typing import List

from .database import get_db
from .schemas import PetCreate, PetUpdate, PetResponse
from .models import row_to_pet_dict

router = APIRouter(prefix="/api/pets", tags=["Pets"])

@router.get("", response_model=List[PetResponse])
def list_pets(db: sqlite3.Connection = Depends(get_db)):
    """
    Fetch all pet profiles from the database.
    Returns an empty array if no pet has been created yet.
    """
    cursor = db.cursor()
    cursor.execute("SELECT * FROM pets ORDER BY created_at DESC;")
    rows = cursor.fetchall()
    return [row_to_pet_dict(r) for r in rows]

@router.post("", response_model=PetResponse, status_code=status.HTTP_201_CREATED)
def create_pet(pet_data: PetCreate, db: sqlite3.Connection = Depends(get_db)):
    """
    Create a new pet profile and save it to SQLite.
    Generates a unique UUID and ISO 8601 timestamps.
    """
    pet_id = str(uuid.uuid4())
    now_iso = datetime.now(timezone.utc).isoformat()
    avatar = pet_data.avatar_symbol if pet_data.avatar_symbol else "pawprint.fill"

    cursor = db.cursor()
    # Parameterized SQL query prevents SQL injection
    cursor.execute("""
        INSERT INTO pets (id, name, species, breed, date_of_birth, avatar_symbol, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?);
    """, (
        pet_id,
        pet_data.name.strip(),
        pet_data.species.strip(),
        pet_data.breed.strip() if pet_data.breed else None,
        pet_data.date_of_birth,
        avatar,
        now_iso,
        now_iso
    ))
    db.commit()

    # Fetch the newly created record to return
    cursor.execute("SELECT * FROM pets WHERE id = ?;", (pet_id,))
    row = cursor.fetchone()
    return row_to_pet_dict(row)

@router.get("/{pet_id}", response_model=PetResponse)
def get_pet(pet_id: str, db: sqlite3.Connection = Depends(get_db)):
    """
    Fetch a single pet profile by its unique ID.
    Raises HTTP 404 if not found.
    """
    cursor = db.cursor()
    cursor.execute("SELECT * FROM pets WHERE id = ?;", (pet_id,))
    row = cursor.fetchone()
    if not row:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Pet with ID '{pet_id}' was not found."
        )
    return row_to_pet_dict(row)

@router.put("/{pet_id}", response_model=PetResponse)
def update_pet(pet_id: str, pet_data: PetUpdate, db: sqlite3.Connection = Depends(get_db)):
    """
    Update details of an existing pet profile.
    Only updates fields that are provided in the request body.
    """
    cursor = db.cursor()
    cursor.execute("SELECT * FROM pets WHERE id = ?;", (pet_id,))
    existing = cursor.fetchone()
    if not existing:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Pet with ID '{pet_id}' was not found."
        )

    # Use existing values if not specified in update payload
    updated_name = pet_data.name.strip() if pet_data.name is not None else existing["name"]
    updated_species = pet_data.species.strip() if pet_data.species is not None else existing["species"]
    updated_breed = pet_data.breed.strip() if pet_data.breed is not None else existing["breed"]
    updated_dob = pet_data.date_of_birth if pet_data.date_of_birth is not None else existing["date_of_birth"]
    updated_avatar = pet_data.avatar_symbol if pet_data.avatar_symbol is not None else existing["avatar_symbol"]
    now_iso = datetime.now(timezone.utc).isoformat()

    cursor.execute("""
        UPDATE pets
        SET name = ?, species = ?, breed = ?, date_of_birth = ?, avatar_symbol = ?, updated_at = ?
        WHERE id = ?;
    """, (updated_name, updated_species, updated_breed, updated_dob, updated_avatar, now_iso, pet_id))
    db.commit()

    cursor.execute("SELECT * FROM pets WHERE id = ?;", (pet_id,))
    updated_row = cursor.fetchone()
    return row_to_pet_dict(updated_row)

