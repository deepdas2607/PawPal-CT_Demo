# PawPal FastAPI & SQLite Backend

This directory contains the Python REST API backend and SQLite database layer for PawPal.

---

## 1. Quickstart

To install dependencies and start the local development server:
```bash
./start_backend.sh
```

The server will start on `http://127.0.0.1:8000`.

---

## 2. Running Automated Tests

Run the full pytest suite with isolated temporary test databases:
```bash
source venv/bin/activate
pytest -v
```

---

## 3. Database Location & Schema

- **Database File**: `backend/data/pawpal.db` (auto-created on startup, excluded from git).
- **Engine**: SQLite 3 with `PRAGMA foreign_keys = ON;`.
- **Tables**:
  - `pets`: Stores pet profiles.
  - `care_activities`: Stores logged walks, meals, medicines.
  - `care_reminders`: Stores upcoming and completed reminders.
  - `pet_tips`: Seeded wellness tips.
  - `saved_tips`: Join table for pet favorite tips.

