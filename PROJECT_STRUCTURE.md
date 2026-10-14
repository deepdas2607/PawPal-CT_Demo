# PawPal Project Architecture & MVVM File Classification

This document explicitly classifies every source file in PawPal into its architectural layer (**Model, View, ViewModel, Service, Utility, or Backend**) and provides an endpoint reference table.

---

## 1. Architectural File Classification

### A. iOS Client (SwiftUI + MVVM)

| File Path | Architectural Layer | Purpose / Responsibility |
|---|---|---|
| `PawPal/PawPalApp.swift` | **App Lifecycle** | Main entry point bootstrapping the SwiftUI App scene. |
| `PawPal/ContentView.swift` | **Root View** | Routes between Onboarding, Dashboard, and Server Offline states. |
| `PawPal/Models/Pet.swift` | **Model** | Represents the pet profile schema, `PetCreateRequest`, and `PetUpdateRequest`. |
| `PawPal/Models/CareActivity.swift` | **Model** | Represents care activities (`ActivityType` enum, `CareActivity`, and create request). |
| `PawPal/Models/CareReminder.swift` | **Model** | Represents care reminders, due dates, completion flags, and update payloads. |
| `PawPal/Models/PetTip.swift` | **Model** | Represents wellness tips and saved favorite states. |
| `PawPal/Models/LiveInspectorLog.swift` | **Model** | Represents an inspection entry in the Live Activity & Payload Inspector. |
| `PawPal/ViewModels/OnboardingViewModel.swift` | **ViewModel** | Manages pet onboarding form state, field validation, and profile creation API calls. |
| `PawPal/ViewModels/DashboardViewModel.swift` | **ViewModel** | Coordinates home dashboard state: active pet, today's activities, upcoming reminders, tips. |
| `PawPal/ViewModels/PetProfileViewModel.swift` | **ViewModel** | Manages viewing, editing, and updating pet profile fields. |
| `PawPal/ViewModels/ActivityLogViewModel.swift` | **ViewModel** | Manages recording care activities and fetching chronological care history. |
| `PawPal/ViewModels/RemindersViewModel.swift` | **ViewModel** | Manages scheduling care alerts, toggling completion, and deleting reminders. |
| `PawPal/ViewModels/TipsViewModel.swift` | **ViewModel** | Manages pet tips catalog, category filters, and favoriting state. |
| `PawPal/ViewModels/LiveInspectorViewModel.swift` | **ViewModel** | Shared singleton managing the real-time activity and payload inspection log buffer. |
| `PawPal/Views/OnboardingView.swift` | **View** | Welcome screen with avatar selector and form to create the initial pet profile. |
| `PawPal/Views/DashboardView.swift` | **View** | Home dashboard displaying pet card, quick action grid, today's care, reminders, tips. |
| `PawPal/Views/PetProfileView.swift` | **View** | Pet profile details screen with in-place editing and metadata. |
| `PawPal/Views/ActivityLogView.swift` | **View** | Care logging screen with activity type chips, duration, time, and history list. |
| `PawPal/Views/RemindersView.swift` | **View** | Manages upcoming and completed reminders with completion checkboxes and swipe-to-delete. |
| `PawPal/Views/AddReminderView.swift` | **View** | Sheet for scheduling a new care reminder and requesting notification permissions. |
| `PawPal/Views/TipsView.swift` | **View** | Wellness tips screen with category filter chips and favorite toggles. |
| `PawPal/Views/LiveInspectorView.swift` | **View** | Developer inspector sheet displaying real-time API logs, response codes, and JSON copy tools. |
| `PawPal/Services/APIClient.swift` | **Service** | Centralized URLSession HTTP client with async/await, JSON decoding, and inspector logging. |
| `PawPal/Services/PetService.swift` | **Service** | API client service for `/api/pets` endpoints. |
| `PawPal/Services/ActivityService.swift` | **Service** | API client service for `/api/pets/{id}/activities` endpoints. |
| `PawPal/Services/ReminderService.swift` | **Service** | API client service for `/api/pets/{id}/reminders` endpoints. |
| `PawPal/Services/TipsService.swift` | **Service** | API client service for `/api/tips` and `/api/pets/{id}/saved-tips`. |
| `PawPal/Services/LocalNotificationService.swift` | **Service** | Apple UserNotifications framework wrapper for scheduling local care alerts. |
| `PawPal/Utilities/AppConfig.swift` | **Utility** | Central configuration file defining the backend URL (`http://127.0.0.1:8000`) and timeouts. |
| `PawPal/Utilities/DateFormatterHelper.swift` | **Utility** | Converts between ISO 8601 strings and user-friendly relative display dates. |
| `PawPal/Utilities/ThemeColors.swift` | **Utility** | Semantic color tokens for consistent card, app, and input styling. |
| `PawPal/Utilities/ViewExtensions.swift` | **Utility** | Cross-platform View extensions for inline navigation titles and toolbar item placement. |

---

### B. Python Backend (FastAPI + SQLite)

| File Path | Architectural Layer | Purpose / Responsibility |
|---|---|---|
| `backend/app/main.py` | **Backend Entry Point** | Initializes FastAPI application, configures CORS, startup lifespan, and routes. |
| `backend/app/database.py` | **Database Layer** | SQLite connection manager (`pawpal.db`), schema creation, and tip seed loader. |
| `backend/app/models.py` | **Data Mapper** | Converts raw SQLite rows into clean dictionaries for Pydantic response models. |
| `backend/app/schemas.py` | **Validation Layer** | Pydantic schemas validating request bodies and enforcing response formats. |
| `backend/app/pet_routes.py` | **Route Controller** | REST API endpoints for `/api/pets` (list, create, get, update). |
| `backend/app/activity_routes.py` | **Route Controller** | REST API endpoints for `/api/pets/{id}/activities` (list, create). |
| `backend/app/reminder_routes.py` | **Route Controller** | REST API endpoints for `/api/pets/{id}/reminders` (list, create, update, delete). |
| `backend/app/tips_routes.py` | **Route Controller** | REST API endpoints for `/api/tips` and `/api/pets/{id}/saved-tips` (list, save, unsave). |
| `backend/start_backend.sh` | **DevOps Script** | One-click shell script that creates `venv`, installs deps, and starts Uvicorn. |
| `backend/requirements.txt` | **Dependencies** | Minimal pinned Python dependencies (FastAPI, Uvicorn, Pydantic, Pytest, HTTPX). |

---

## 2. REST API Specification & Endpoint Reference

| Method | Endpoint | Description | Request Body | Response Status |
|---|---|---|---|---|
| **GET** | `/health` | Server health & SQLite check | None | `200 OK` |
| **GET** | `/api/pets` | List all pet profiles | None | `200 OK` |
| **POST** | `/api/pets` | Create a new pet profile | `PetCreate` | `201 Created` |
| **GET** | `/api/pets/{pet_id}` | Fetch pet profile by ID | None | `200 OK` / `404` |
| **PUT** | `/api/pets/{pet_id}` | Update existing pet profile | `PetUpdate` | `200 OK` / `404` |
| **GET** | `/api/pets/{pet_id}/activities` | List care activities for pet | None | `200 OK` / `404` |
| **POST** | `/api/pets/{pet_id}/activities` | Record a new care activity | `ActivityCreate` | `201 Created` / `404` |
| **GET** | `/api/pets/{pet_id}/reminders` | List reminders for pet | None | `200 OK` / `404` |
| **POST** | `/api/pets/{pet_id}/reminders` | Create care reminder | `ReminderCreate` | `201 Created` / `404` |
| **PATCH** | `/api/reminders/{reminder_id}` | Update reminder status | `ReminderUpdate` | `200 OK` / `404` |
| **DELETE** | `/api/reminders/{reminder_id}` | Delete reminder | None | `200 OK` / `404` |
| **GET** | `/api/tips` | Fetch all wellness tips | None | `200 OK` |
| **GET** | `/api/pets/{pet_id}/saved-tips` | Fetch saved tip IDs for pet | None | `200 OK` / `404` |
| **PUT** | `/api/pets/{pet_id}/saved-tips/{tip_id}` | Save tip to favorites | None | `200 OK` / `404` |
| **DELETE**| `/api/pets/{pet_id}/saved-tips/{tip_id}` | Remove tip from favorites | None | `200 OK` / `404` |

