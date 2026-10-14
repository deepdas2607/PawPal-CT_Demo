"""
Database Helper Models and Row Serializers.
Converts raw SQLite rows into clean dictionaries for Pydantic responses.
"""

import sqlite3
from typing import Dict, Any

def row_to_pet_dict(row: sqlite3.Row) -> Dict[str, Any]:
    """Converts a SQLite row from the 'pets' table into a clean dictionary."""
    return {
        "id": row["id"],
        "name": row["name"],
        "species": row["species"],
        "breed": row["breed"],
        "date_of_birth": row["date_of_birth"],
        "avatar_symbol": row["avatar_symbol"],
        "created_at": row["created_at"],
        "updated_at": row["updated_at"],
    }

def row_to_activity_dict(row: sqlite3.Row) -> Dict[str, Any]:
    """Converts a SQLite row from 'care_activities' into a clean dictionary."""
    return {
        "id": row["id"],
        "pet_id": row["pet_id"],
        "activity_type": row["activity_type"],
        "timestamp": row["timestamp"],
        "duration_minutes": row["duration_minutes"],
        "notes": row["notes"],
        "created_at": row["created_at"],
    }

def row_to_reminder_dict(row: sqlite3.Row) -> Dict[str, Any]:
    """Converts a SQLite row from 'care_reminders' into a clean dictionary."""
    return {
        "id": row["id"],
        "pet_id": row["pet_id"],
        "title": row["title"],
        "notes": row["notes"],
        "due_date": row["due_date"],
        "is_completed": bool(row["is_completed"]),
        "completed_at": row["completed_at"],
        "created_at": row["created_at"],
    }

def row_to_tip_dict(row: sqlite3.Row, is_saved: bool = False) -> Dict[str, Any]:
    """Converts a SQLite row from 'pet_tips' into a clean dictionary."""
    return {
        "id": row["id"],
        "title": row["title"],
        "content": row["content"],
        "category": row["category"],
        "icon_name": row["icon_name"],
        "is_saved": is_saved,
    }

