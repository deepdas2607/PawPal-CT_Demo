"""
Database Connection and Initialization for PawPal.
Uses Python's built-in SQLite database engine (zero cloud configuration required).
Stores data reliably in backend/data/pawpal.db.
"""

import os
import sqlite3
from typing import Generator

# Path where SQLite database file is persisted
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(BASE_DIR, "data")
DB_PATH = os.path.join(DATA_DIR, "pawpal.db")

def get_db_connection() -> sqlite3.Connection:
    """
    Creates and returns a new connection to the local SQLite database.
    Enables foreign keys and dictionary-like row access.
    """
    # Ensure data folder exists before connecting
    os.makedirs(DATA_DIR, exist_ok=True)
    
    conn = sqlite3.connect(DB_PATH)
    # Enable foreign keys constraint enforcement in SQLite
    conn.execute("PRAGMA foreign_keys = ON;")
    # Return rows as dictionary-like objects (access columns by name)
    conn.row_factory = sqlite3.Row
    return conn

def get_db() -> Generator[sqlite3.Connection, None, None]:
    """
    FastAPI dependency that yields a database connection and safely closes it after the request.
    """
    conn = get_db_connection()
    try:
        yield conn
    finally:
        conn.close()

def initialize_database():
    """
    Initializes database tables if they do not already exist,
    and seeds initial pet care tips.
    """
    os.makedirs(DATA_DIR, exist_ok=True)
    conn = get_db_connection()
    cursor = conn.cursor()

    # 1. Table for Pet Profiles
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS pets (
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

    # 2. Table for Care Activities (walking, feeding, grooming, meds, etc.)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS care_activities (
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

    # 3. Table for Care Reminders (feeding, vet visit, medication alerts)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS care_reminders (
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

    # 4. Table for Pet Care Tips
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS pet_tips (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL,
        icon_name TEXT NOT NULL
    );
    """)

    # 5. Table for Saved / Favorite Tips per Pet
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS saved_tips (
        pet_id TEXT NOT NULL,
        tip_id TEXT NOT NULL,
        saved_at TEXT NOT NULL,
        PRIMARY KEY (pet_id, tip_id),
        FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE,
        FOREIGN KEY (tip_id) REFERENCES pet_tips(id) ON DELETE CASCADE
    );
    """)

    # Seed pet tips idempotently (insert only if they don't exist)
    sample_tips = [
        (
            "tip-hydration",
            "Keep Fresh Water Accessible",
            "Always keep a clean bowl of fresh water available. Pets need about 50-60ml of water per kg of body weight daily.",
            "Nutrition",
            "drop.fill"
        ),
        (
            "tip-exercise",
            "Daily Exercise & Mental Stimulation",
            "Active play and daily walks help maintain physical health, healthy weight, and prevent anxiety or destructive habits.",
            "Exercise",
            "figure.walk"
        ),
        (
            "tip-brushing",
            "Regular Coat Grooming",
            "Brushing your pet's fur removes loose hair, prevents painful mats, and distributes natural oils across their coat.",
            "Care",
            "comb.fill"
        ),
        (
            "tip-teeth",
            "Dental Health Checks",
            "Regular dental chews and brushing prevent tartar buildup, gum disease, and systemic organ infections.",
            "Wellness",
            "heart.text.square.fill"
        ),
        (
            "tip-vet",
            "Annual Wellness Checks",
            "Schedule yearly veterinary visits for core vaccinations, parasite prevention, and routine health screenings.",
            "Wellness",
            "cross.case.fill"
        )
    ]

    for tip in sample_tips:
        cursor.execute("""
        INSERT OR IGNORE INTO pet_tips (id, title, content, category, icon_name)
        VALUES (?, ?, ?, ?, ?)
        """, tip)

    conn.commit()
    conn.close()

