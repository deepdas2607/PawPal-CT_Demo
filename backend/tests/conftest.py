"""
Pytest Fixtures for PawPal Backend Tests.
Provides a test client configured with an isolated temporary SQLite test
database.
"""

import os
import sqlite3
import tempfile

import pytest
from fastapi.testclient import TestClient

from app.database import get_db
from app.main import app


@pytest.fixture(autouse=True)
def test_db():
    """
    Creates an isolated temporary SQLite database for each test function.
    Cleans up the temporary database file after the test finishes.
    """
    temp_dir = tempfile.mkdtemp()
    temp_db_path = os.path.join(temp_dir, "test_pawpal.db")

    conn = sqlite3.connect(temp_db_path)
    conn.execute("PRAGMA foreign_keys = ON;")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    # Create tables
    cursor.execute("""
    CREATE TABLE pets (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        species TEXT NOT NULL,
        breed TEXT,
        date_of_birth TEXT,
        avatar_symbol TEXT DEFAULT 'pawprint.fill',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
    );
    """)

    cursor.execute("""
    CREATE TABLE care_activities (
        id TEXT PRIMARY KEY,
        pet_id TEXT NOT NULL,
        activity_type TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        duration_minutes INTEGER,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE
    );
    """)

    cursor.execute("""
    CREATE TABLE care_reminders (
        id TEXT PRIMARY KEY,
        pet_id TEXT NOT NULL,
        title TEXT NOT NULL,
        notes TEXT,
        due_date TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0,
        completed_at TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE
    );
    """)

    cursor.execute("""
    CREATE TABLE pet_tips (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL,
        icon_name TEXT NOT NULL
    );
    """)

    cursor.execute("""
    CREATE TABLE saved_tips (
        pet_id TEXT NOT NULL,
        tip_id TEXT NOT NULL,
        saved_at TEXT NOT NULL,
        PRIMARY KEY (pet_id, tip_id),
        FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE,
        FOREIGN KEY (tip_id) REFERENCES pet_tips(id) ON DELETE CASCADE
    );
    """)

    # Seed tips
    cursor.execute("""
    INSERT INTO pet_tips (id, title, content, category, icon_name)
    VALUES (
        'tip-hydration',
        'Hydration',
        'Always keep fresh water available.',
        'Nutrition',
        'drop.fill'
    );
    """)

    conn.commit()

    def override_get_db():
        test_conn = sqlite3.connect(temp_db_path)
        test_conn.execute("PRAGMA foreign_keys = ON;")
        test_conn.row_factory = sqlite3.Row
        try:
            yield test_conn
        finally:
            test_conn.close()

    app.dependency_overrides[get_db] = override_get_db

    yield conn

    conn.close()
    app.dependency_overrides.clear()
    if os.path.exists(temp_db_path):
        os.remove(temp_db_path)
    if os.path.exists(temp_dir):
        os.rmdir(temp_dir)


@pytest.fixture
def client():
    """Returns a FastAPI TestClient configured to use the test database."""
    return TestClient(app)
