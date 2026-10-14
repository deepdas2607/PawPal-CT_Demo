# PawPal 🐾 — iOS Pet-Care Companion Application

PawPal is a native iOS pet-care companion application built with **SwiftUI (MVVM)**, supported by a genuine local **FastAPI** backend and an actual **SQLite database**.

---

## 1. Executive Summary

PawPal allows pet parents to manage their pet's daily well-being:
- **Onboarding & Profile**: Create and customize your pet's profile (name, species, breed, birthday, avatar icon).
- **Daily Dashboard**: View today's care stats, upcoming reminders, quick actions, and daily care tips.
- **Care Activity Logging**: Record daily care events (walking, feeding, grooming, medications, vet visits) with duration and notes.
- **Care Reminders**: Schedule upcoming pet care alerts with Apple's native UserNotifications framework.
- **Pet Care Tips**: Browse curated veterinary tips with category filtering and save personal favorites.
- **Live Activity & Payload Inspector**: Built-in developer sheet for inspecting real-time API requests, responses, and JSON payloads with one-tap clipboard copy.

---

## 2. Architecture Overview

### A. Frontend Architecture (iOS / SwiftUI / MVVM)
The client follows a clean, uncomplicated **Model-View-ViewModel (MVVM)** design pattern with zero third-party UI dependencies:

```text
SwiftUI View
    ↓ (User actions)
ViewModel (ObservableObject / @Published state)
    ↓ (Domain requests)
Service Layer (PetService, ActivityService, ReminderService, TipsService)
    ↓ (HTTP + JSON encoding/decoding)
APIClient (URLSession async/await + Live Inspector Logger)
```

- **Models (`PawPal/Models/`)**: Codable data structures mirroring the backend SQLite schema.
- **Views (`PawPal/Views/`)**: Responsive SwiftUI views with accessible contrast and 44x44pt touch targets.
- **ViewModels (`PawPal/ViewModels/`)**: Screen state management, input validation, and asynchronous coordination.
- **Services (`PawPal/Services/`)**: Network service facades and native iOS local notification managers.
- **Utilities (`PawPal/Utilities/`)**: Central configuration, date formatting, and semantic color tokens.

### B. Backend Architecture (FastAPI + SQLite)
- **Framework**: Python FastAPI with Uvicorn.
- **Database**: Python built-in `sqlite3` relational database stored locally at `backend/data/pawpal.db`.
- **Validation**: Pydantic v2 schemas validating request bodies and enforcing response formats.
- **Zero Cloud Dependence**: Operates 100% locally with zero cloud database accounts, Docker, or Homebrew needed.

---

## 3. Directory Layout

```text
PawPal/
├── PawPal/                          # iOS Source Code
│   ├── PawPalApp.swift              # App entry point
│   ├── ContentView.swift            # Root router (Onboarding / Dashboard / Offline)
│   ├── Models/                      # MVVM Models (Pet, CareActivity, CareReminder, PetTip, LiveInspectorLog)
│   ├── Views/                       # MVVM Views (Dashboard, Onboarding, ActivityLog, Reminders, Tips, Inspector)
│   ├── ViewModels/                  # MVVM ViewModels (State management & API coordination)
│   ├── Services/                    # Domain Services (APIClient, PetService, ReminderService, NotificationService)
│   ├── Utilities/                   # Helpers (AppConfig, DateFormatterHelper, ThemeColors, ViewExtensions)
│   └── Assets.xcassets              # App icons and accent color sets
├── PawPal.xcodeproj                 # Xcode project file (uses PBXFileSystemSynchronizedRootGroup)
│
├── backend/                         # Local Python FastAPI Backend
│   ├── app/
│   │   ├── main.py                  # Server entry point, CORS, and health endpoint
│   │   ├── database.py              # SQLite connection, table DDL, and tip seed loader
│   │   ├── models.py                # Database row serializers
│   │   ├── schemas.py               # Pydantic validation schemas
│   │   ├── pet_routes.py            # /api/pets endpoints
│   │   ├── activity_routes.py       # /api/pets/{id}/activities endpoints
│   │   ├── reminder_routes.py       # /api/pets/{id}/reminders endpoints
│   │   └── tips_routes.py           # /api/tips endpoints
│   ├── tests/                       # Pytest test suite (11 unit/integration tests)
│   ├── data/                        # SQLite storage directory (pawpal.db)
│   ├── requirements.txt             # Minimal Python dependencies
│   └── start_backend.sh             # One-click startup script
│
├── PROJECT_STRUCTURE.md             # Detailed MVVM file classification and API reference
└── prompt.md                        # Master project specification
```

---

## 4. Prerequisites

1. **Mac** with macOS Sonoma or later.
2. **Xcode** (Version 15 or 16 recommended).
3. **Python 3.10+** (Python 3.15 installed on this Mac).

---

## 5. How to Run

### Step 1: Start the Backend Server
Open your terminal and run the one-click startup script:
```bash
./backend/start_backend.sh
```
This script will:
- Create a Python virtual environment at `backend/venv` (if not already created).
- Install all dependencies (`fastapi`, `uvicorn`, `pydantic`, `pytest`, `httpx`).
- Initialize the SQLite database and seed initial wellness tips.
- Start the server at `http://127.0.0.1:8000`.

### Step 2: Verify Backend Health
- Open your browser to `http://127.0.0.1:8000/health` (should return `{"status":"ok","database":"connected","version":"1.0.0"}`).
- Interactive Swagger documentation is available at `http://127.0.0.1:8000/docs`.

### Step 3: Run the Backend Tests
```bash
cd backend
source venv/bin/activate
pytest
```
Expected output: **11 passed in ~0.12s**.

### Step 4: Open and Run in Xcode
1. Double-click `PawPal.xcodeproj` to open the project in Xcode.
2. Select an iOS Simulator device (e.g., **iPhone 16 Pro** or **iPhone 15**).
3. Press **Run** (`Cmd + R`).

---

## 6. Development Networking Configuration (ATS)

In local development, the iOS Simulator communicates with the local FastAPI server over plaintext HTTP (`http://127.0.0.1:8000`).
Apple's App Transport Security (ATS) requires exceptions for local cleartext networking.
In `PawPal.xcodeproj`, the following build keys are enabled:
- `INFOPLIST_KEY_NSAppTransportSecurity_NSAllowsLocalNetworking = YES;`
- `INFOPLIST_KEY_NSAppTransportSecurity_NSAllowsArbitraryLoads = YES;`

> [!NOTE]
> For production deployment with HTTPS, replace the `baseURL` in `PawPal/Utilities/AppConfig.swift` with your production domain and remove the arbitrary loads ATS exception.

---

## 7. Separate CleverTap Training Integration Lab

Per project specifications, all future CleverTap learning exercises, event schemas, user profiles, APNs push guides, In-App messaging examples, and Postman collections are strictly isolated in:

```text
~/Documents/GitHub/integrations/pawpal_int/
```

The main PawPal application contains **zero CleverTap SDK imports, packages, or tracking calls**. The app functions 100% independently.
