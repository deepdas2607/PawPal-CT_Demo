# Antigravity Master Prompt — Build PawPal iOS App + Working Backend + Separate CleverTap Training Integrations

Act as a senior iOS developer, backend developer, software architect, and QA engineer. Build **PawPal**, a simple but polished native iOS pet-care companion app, with a genuinely working backend, database, and REST API.

I am a beginner, so I need the implementation to be easy to understand, run, debug, and extend. Prioritize correctness and simplicity over unnecessary features or complicated architecture.

**Do not just give me a plan or code snippets. Implement the project, run the available checks, fix errors, and document exactly what works and what remains blocked.**

## 1. Start by inspecting my existing setup

Before changing any files:

1. Inspect the currently open PawPal project and identify the actual project root, Xcode project, scheme, and files already present.
2. Inspect these existing projects in read-only mode to understand their conventions for integration separation, naming, documentation, and comments:
   - `~/Documents/Github/integrations/focusflow_int/`
   - `~/Documents/Github/integrations/queueup_int/`
3. Do not modify, rename, delete, move, or overwrite anything in either existing project.
4. Check which files and folders already exist at `~/Documents/Github/integrations/Pawpal_int/`. Preserve any existing useful work.
5. Inspect the installed Xcode version, available simulator devices, Python version, and the available tools before choosing commands.

If either reference project is unavailable, state that briefly and continue with the requirements in this prompt. Do not invent details about projects you could not inspect.

Do not create duplicate nested projects or move the existing Xcode project unnecessarily. Use its existing location as the main app root.

## 2. Strict project separation requirements

There must be two completely separate deliverables.

### A. Main PawPal application

The main application must contain:

- A native SwiftUI iOS frontend.
- An MVVM-based structure.
- A working Python FastAPI backend.
- A working SQLite database.
- A working REST API connecting the app to the backend.
- Local iOS notifications for saved care reminders, where permissions permit them.
- Tests, setup instructions, and understandable documentation.

**The main PawPal application must contain no CleverTap integration at this stage.**

Do not add the CleverTap SDK through Swift Package Manager, CocoaPods, or any other installation method. Do not import `CleverTapSDK`, create a CleverTap manager in the main app, record CleverTap events, or add CleverTap configuration keys.

Do not create a CleverTap folder inside the main iOS app.

The main app must work independently without a CleverTap account, credentials, SDK, or dashboard.

### B. Separate CleverTap training integrations

Put all future CleverTap learning materials and implementation examples in this exact directory:

`~/Documents/Github/integrations/Pawpal_int/`

Create the directory if it does not exist. Use the actual directory spelling and capitalization present on this Mac if it differs.

This directory will be my **CleverTap integration lab**. I will use its contents one feature at a time as my CleverTap training plan progresses.

Keep all CleverTap-specific code, integration examples, configuration instructions, documentation, and test checklists here. These materials must not be included in the main Xcode app target or required to build the main app.

## 3. App concept and scope

PawPal is a simple pet-care companion for someone who owns a pet and wants to manage its daily care.

Build a clean, modern, friendly iOS interface. Use SwiftUI, system components, SF Symbols, sensible spacing, accessible text, and a small consistent colour palette. Avoid external image APIs, paid services, complicated animations, and features that require unnecessary credentials.

Implement these core screens and flows:

### A. Onboarding and pet profile

Allow the user to create a pet profile with:

- Pet name — required.
- Species — for example, dog, cat, or other.
- Breed — optional.
- Date of birth — optional.
- A simple pet emoji or SF Symbol for the profile.

Validate inputs and show understandable error messages.

Save the profile through the backend API and database. Do not pretend that a profile is saved before the server confirms it.

On future launches, load the profile from the backend and navigate to the dashboard when appropriate. Do not create duplicate profiles every time the app starts.

### B. Home dashboard

Display useful information for the selected pet:

- Pet name and basic profile details.
- Today's care activities.
- Upcoming reminders.
- A few pet-care tips.
- Clear actions to log an activity, add a reminder, view tips, and open the pet profile.

Show loading, empty, success, and error states where appropriate. Add retry actions when a request fails.

### C. Care activity logging

Allow the user to create care activity records for actions such as:

- Walking.
- Feeding.
- Grooming.
- Medication.
- Vet visits.
- Playtime.
- Other.

Each record can contain an activity type, date and time, optional duration, and optional notes.

After the user saves an activity:

1. Validate the input.
2. Send the request to the backend.
3. Store the record in SQLite.
4. Confirm success only after receiving a successful API response.
5. Refresh the dashboard and activity history from the backend.

Persist records across application restarts.

### D. Reminders

Allow the user to:

- Create a care reminder with a title, optional notes, and due date/time.
- See upcoming and completed reminders.
- Mark a reminder as completed.
- Delete a reminder after confirmation.

Persist reminders in SQLite through the API.

Use Apple's native UserNotifications framework for local notifications. Ask for notification permission at an appropriate point rather than immediately displaying a permission prompt when the application launches.

If permission is denied, the reminder must still be saved on the backend and displayed in the app. Explain that the system notification was not scheduled rather than treating the entire save operation as a failure.

Schedule appropriate future reminders, handle invalid or past dates safely, cancel the corresponding scheduled notification when a reminder is deleted, and avoid duplicate notification identifiers.

Do not implement remote push notifications in the main application as part of this stage.

### E. Pet-care tips

Fetch a small set of sample pet-care tips from the backend.

Display each tip in a simple, readable format. Include a way to save and unsave favourite tips, and persist that preference through the API.

Use sensible sample content stored or seeded by the backend. Do not depend on an external content service.

### F. Profile and navigation

Provide straightforward navigation between the dashboard, pet profile, activity history, reminders, and tips.

Keep the UI simple enough for a beginner to understand. Include appropriate empty states, form validation, loading indicators, error alerts, and retry options.

Do not add authentication, accounts, payments, social feeds, chatbots, or other unrelated features. This first version is a single-user learning project.

## 4. iOS architecture — SwiftUI + MVVM

Use Apple's native SwiftUI framework and an uncomplicated **Model–View–ViewModel (MVVM)** architecture.

Use separate folders for the architecture layers and avoid putting the entire application into one large Swift file.

Use a structure similar to the following, adapting it only when the existing Xcode project requires a different layout:

```text
PawPal/
├── PawPalApp.swift
├── Models/
│   ├── Pet.swift
│   ├── CareActivity.swift
│   ├── CareReminder.swift
│   └── PetTip.swift
├── Views/
│   ├── OnboardingView.swift
│   ├── DashboardView.swift
│   ├── PetProfileView.swift
│   ├── ActivityLogView.swift
│   ├── RemindersView.swift
│   ├── AddReminderView.swift
│   └── TipsView.swift
├── ViewModels/
│   ├── OnboardingViewModel.swift
│   ├── DashboardViewModel.swift
│   ├── PetProfileViewModel.swift
│   ├── ActivityLogViewModel.swift
│   ├── RemindersViewModel.swift
│   └── TipsViewModel.swift
├── Services/
│   ├── APIClient.swift
│   ├── PetService.swift
│   ├── ActivityService.swift
│   ├── ReminderService.swift
│   ├── TipsService.swift
│   └── LocalNotificationService.swift
├── Utilities/
│   └── AppConfig.swift
└── Resources/
```

This is an example structure, not a requirement to create empty or unused files. Only create files that are necessary for the implemented application.

### MVVM rules

- **Models:** represent application data, API request/response structures, and data types.
- **Views:** display the UI, accept input, and forward user actions to their ViewModels.
- **ViewModels:** manage screen state, validate screen-level input, coordinate service calls, and expose data for SwiftUI views.
- **Services:** communicate with the backend or perform a clearly defined system task, such as scheduling local notifications.
- **APIClient:** centralize HTTP requests, response validation, JSON encoding/decoding, and common error handling.
- **AppConfig:** centralize the backend base URL and other simple app configuration.

Do not put network requests directly inside SwiftUI View files. Do not duplicate API logic in multiple ViewModels.

Use asynchronous Swift concurrency (`async`/`await`) with appropriate main-thread state updates. Prevent stale or overlapping requests from producing inconsistent screen state where necessary.

Use `Codable` for suitable models and request/response types. Keep models aligned with the backend API contract.

Make sure the files are actually included in the Xcode project or correctly discovered by its project configuration. A file merely existing on disk does not prove it is part of the build.

## 5. Backend — FastAPI + SQLite

Create a simple backend in a `backend/` directory inside the main PawPal project root.

Use:

- Python.
- FastAPI for REST endpoints.
- Uvicorn for running the local server.
- SQLite through Python's built-in `sqlite3` module.
- Pydantic request and response validation.
- Pytest and suitable FastAPI testing utilities for backend tests.

Do not require Docker, PostgreSQL, cloud hosting, a third-party database account, or Homebrew.

Keep dependencies minimal and verify that their versions work with the Python interpreter actually installed on this Mac.

Use a structure similar to:

```text
backend/
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── database.py
│   ├── models.py
│   ├── schemas.py
│   ├── pet_routes.py
│   ├── activity_routes.py
│   ├── reminder_routes.py
│   └── tips_routes.py
├── tests/
│   ├── test_health.py
│   ├── test_pets.py
│   ├── test_activities.py
│   ├── test_reminders.py
│   └── test_tips.py
├── data/
├── requirements.txt
├── .gitignore
└── start_backend.sh
```

You may use a simpler layout where appropriate, but separate route handling, database operations, validation schemas, and tests so that the code remains easy to follow.

### Database requirements

Create SQLite tables for:

- Pets.
- Care activities.
- Care reminders.
- Saved pet-care tips or saved-tip relationships.
- Pet-care tips, if they are stored as database records.

Use UUIDs or another consistent identifier strategy and document it.

Define primary keys, foreign keys, appropriate constraints, and useful indexes where justified. Enable SQLite foreign-key enforcement on database connections.

Use parameterized SQL statements. Never build SQL commands by directly concatenating user input.

Persist the database in a predictable location such as `backend/data/pawpal.db`. Ensure that the database and Python virtual environment are excluded from Git.

Initialize the database automatically when the backend starts. Seed a few safe example pet-care tips in an idempotent way, meaning restarting the backend must not create duplicate tips.

Use consistent date/time formats for API communication, preferably ISO 8601. Handle time zones consistently and display local times appropriately in the app.

Do not store a fake pet profile simply to make the dashboard look populated. A newly installed app should show onboarding when no pet profile exists.

### Required REST API

Implement and document at least these endpoints:

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/health` | Check server health and database availability. |
| GET | `/api/pets` | Fetch the existing pet profile. |
| POST | `/api/pets` | Create a pet profile. |
| GET | `/api/pets/{pet_id}` | Fetch an individual pet. |
| PUT or PATCH | `/api/pets/{pet_id}` | Update an existing pet profile. |
| GET | `/api/pets/{pet_id}/activities` | Fetch a pet's activity history. |
| POST | `/api/pets/{pet_id}/activities` | Create a care activity. |
| GET | `/api/pets/{pet_id}/reminders` | Fetch reminders. |
| POST | `/api/pets/{pet_id}/reminders` | Create a reminder. |
| PATCH | `/api/reminders/{reminder_id}` | Update a reminder, including completion status. |
| DELETE | `/api/reminders/{reminder_id}` | Delete a reminder. |
| GET | `/api/tips` | Fetch the pet-care tips. |
| GET | `/api/pets/{pet_id}/saved-tips` | Fetch a pet's saved tips. |
| PUT | `/api/pets/{pet_id}/saved-tips/{tip_id}` | Save a tip. |
| DELETE | `/api/pets/{pet_id}/saved-tips/{tip_id}` | Unsave a tip. |

You may refine endpoint names if the entire app and documentation consistently use the same contract. Do not leave any required feature connected to a non-existent endpoint.

For every endpoint:

- Validate the request body and route parameters.
- Return appropriate HTTP status codes.
- Return consistent JSON response structures.
- Return useful error details without leaking internal exceptions.
- Handle missing records and invalid input correctly.
- Ensure database transactions are committed or rolled back appropriately.

Add FastAPI's generated interactive API documentation and verify it is accessible at `/docs` when the backend is running.

Keep the backend simple. There is no need to build authentication for this local, single-user learning project, but document clearly that it is not a production-secured service.

## 6. Make the entire request-to-database flow work

Implement real communication between the iOS app and FastAPI. Do not implement a UI that only uses in-memory arrays, fake API responses, or hardcoded success messages.

The data flow must be:

```text
SwiftUI View
    ↓
ViewModel
    ↓
Service / APIClient
    ↓ HTTP + JSON
FastAPI endpoint
    ↓
Validation + database logic
    ↓
SQLite database
    ↓
API response
    ↓
ViewModel updates state
    ↓
SwiftUI renders confirmed data
```

Use a single configurable development API base URL.

The iOS Simulator should be able to reach the backend running on the Mac. Start with the appropriate loopback URL for the simulator and verify it using a real request. Do not assume connectivity works just because the server starts.

Configure App Transport Security as narrowly as necessary for local HTTP development. Do not enable unrestricted cleartext networking unnecessarily. Clearly document any development-only exception and how it should be removed or replaced with HTTPS for deployment.

Provide graceful handling for:

- A server that is not running.
- Network timeouts.
- HTTP 4xx and 5xx responses.
- Invalid or unexpected JSON.
- Empty datasets.
- A pet profile that does not exist.
- Duplicate creation attempts.
- Expired or invalid reminders.
- A database that cannot be opened.

Never silently substitute fake data when a backend request fails. Show an understandable error and a retry action.

## 7. Code comments and beginner-friendly documentation

This requirement is very important.

I want the code documented at a level similar to how the FocusFlow and QueueUp integration projects were intended to be documented.

**Explain the purpose of every function and the logic inside each function.**

Apply the following rules to both Swift and Python:

1. Add a clear file-level comment explaining the file's responsibility.
2. Add documentation comments to every class, struct, enum, protocol, and important property where their purpose is not obvious.
3. Document every function, method, initializer, and important computed property. Explain what it does, what its inputs represent, and what it returns or changes.
4. Add explanatory inline comments before every meaningful operation or logical block, especially API calls, database queries, state changes, asynchronous operations, JSON conversion, validation, error handling, date conversion, and notification scheduling.
5. Explain why important decisions were made, not just what the syntax does.
6. Add comments explaining how important functions connect to other files and parts of the application.
7. Explain Swift-specific concepts, such as `@State`, `@StateObject` or `@Observable` where applicable, `@Published` if used, `async`/`await`, `Codable`, and dependency injection when they appear.
8. Explain Python concepts when useful, including request schemas, route handlers, database connections, transactions, exceptions, and test fixtures.
9. Avoid meaningless comments that repeat obvious syntax or add comments to closing braces just to increase comment count. Comments should explain actual logic and be useful to a beginner.
10. Keep comments accurate whenever code changes. Do not leave outdated comments.

Add a `README.md` at the main project root with:

- What PawPal does.
- The app architecture.
- The backend architecture.
- Folder and file explanations.
- Prerequisites.
- How to configure and start the backend.
- How to open, build, and run the app in Xcode.
- How to check whether the API and database are working.
- How to run backend tests and any available iOS tests.
- Common errors and their fixes.
- What is implemented and what is not.
- An explanation of the development-only networking configuration.

Add a `PROJECT_STRUCTURE.md` that lists the important files and explicitly identifies which belong to **Models, Views, ViewModels, Services, Utilities, and Backend**.

For example, it must clearly state that `DashboardView.swift` is a View, `DashboardViewModel.swift` is a ViewModel, and `Pet.swift` is a Model. Do this for every important file you create. Do not make me guess which category a file belongs to.

Include a short API reference containing all endpoints, example request/response JSON, and any important validation rules.

## 8. Separate CleverTap training integration directory

Create the CleverTap training files ONLY in:

`~/Documents/Github/integrations/Pawpal_int/`

This directory must remain separate from the main iOS application.

Use a simple structure similar to:

```text
Pawpal_int/
├── README.md
├── TRAINING_PLAN.md
├── 01_SDK_Setup/
│   ├── README.md
│   └── SDK_Setup_Checklist.md
├── 02_SDK_Initialization/
│   ├── README.md
│   └── CleverTapManager.swift.example
├── 03_Custom_Events/
│   ├── README.md
│   ├── CleverTapEvents.swift.example
│   └── Event_Catalog.md
├── 04_User_Profiles/
│   ├── README.md
│   └── Profile_Examples.swift.example
├── 05_Push_Notifications/
│   ├── README.md
│   └── Push_Integration_Examples.swift.example
├── 06_In_App_Messaging/
│   ├── README.md
│   └── InApp_Integration_Examples.swift.example
├── 07_App_Inbox/
│   ├── README.md
│   └── AppInbox_Integration_Examples.swift.example
├── 08_Remote_Config/
│   ├── README.md
│   └── RemoteConfig_Examples.swift.example
└── 09_Testing_and_Debugging/
    └── README.md
```

Adapt the files to the current official SDK and the actual learning requirements. Do not create empty files or duplicate the same generic code in every directory.

Use `.swift.example` for standalone learning examples so that they cannot accidentally compile into the main iOS app. If a different example format is more suitable, explain why. These are training references, not files that should be added automatically to PawPal.

### CleverTap training phases

**Phase 1 — SDK setup and initialization**

Document how the SDK is added later using Swift Package Manager, how required configuration is supplied, and how to verify that initialization works. Keep all installation steps separate from the current app build.

**Phase 2 — Custom events**

Create a clear event catalog for relevant PawPal actions, including:

- `Onboarding Completed`
- `Pet Profile Created`
- `Care Activity Logged`
- `Reminder Created`
- `Reminder Completed`
- `Pet Tip Viewed`
- `Pet Tip Saved`
- `Pet Tip Unsaved`

For each event, document its trigger, example properties, property data types, purpose, and a test procedure.

Write example Swift code that is easy to copy into the appropriate layer later. Avoid sending pet-owner personal information or unnecessary data in event properties.

**Phase 3 — User profiles**

Explain how user profile properties work and show appropriate examples. Distinguish profile attributes from event properties. Since the initial PawPal app does not implement login or a verified user identity, explain the anonymous profile flow and mark login-specific identity handling as optional advanced material rather than inventing a login system.

**Phase 4 — Push notifications**

Explain the iOS capabilities, permission flow, device registration, Apple Push Notification service requirements, CleverTap dashboard configuration, and testing process. Identify which setup steps require an Apple Developer account or credentials. Never fabricate credentials or claim that remote push works on a simulator.

**Phase 5 — In-App Messaging**

Document SDK requirements, testing setup, supported message behaviour, and any necessary delegates or callbacks according to the current official documentation.

**Phase 6 — App Inbox**

Document how to enable and test App Inbox, the relevant SDK APIs, and how it can later be connected to a SwiftUI interface.

**Phase 7 — Remote Config**

Document supported variable types, setup, sample values, fetching or synchronization behaviour, and ways to validate that a changed configuration affects the app.

**Phase 8 — Testing and debugging**

Include troubleshooting steps for SDK installation, initialization, event delivery, profile updates, push configuration, and messaging. Explain how to confirm results in the CleverTap dashboard and how to distinguish an app-code problem from a dashboard or credentials configuration problem.

### Official documentation requirement

Use these official sources as starting points and check their current contents before writing integration examples:

- iOS SDK overview: https://developer.clevertap.com/docs/ios
- iOS Quick Start Guide: https://developer.clevertap.com/docs/ios-quickstart-guide
- User Events: https://developer.clevertap.com/docs/user-events-ios
- User Profiles: https://developer.clevertap.com/docs/user-profiles-ios
- Push Notifications: https://developer.clevertap.com/docs/push-notifications-ios
- In-App Notifications: https://developer.clevertap.com/docs/in-app-notification-ios
- App Inbox: https://developer.clevertap.com/docs/app-inbox-ios
- Remote Config / Product Experiences: https://developer.clevertap.com/docs/ios-remote-config
- Official iOS SDK repository: https://github.com/CleverTap/clevertap-ios-sdk

If any URL has moved or an API has changed, locate the current official documentation instead of guessing. Record the sources and SDK-version assumptions in the relevant README files.

Do not invent SDK method names, package versions, dashboard options, or configuration keys. Label snippets that require credentials or dashboard setup. Use placeholders only for values that I must supply.

### Separation verification

At the end, check that:

- The main app does not import CleverTap.
- The main Xcode project does not include the CleverTap package.
- No CleverTap configuration or event code has been added to the main app.
- The training examples are located exclusively in `Pawpal_int`.
- Every training phase explains how to implement and test that feature later.
- Existing FocusFlow and QueueUp files remain unchanged.

## 9. Testing — prove each layer works

Do not declare success merely because code files were created.

### Backend tests

Write automated tests covering:

- Health endpoint and database connectivity.
- Creating, fetching, and updating a pet.
- Invalid pet input and missing pet identifiers.
- Creating and fetching care activities.
- Creating, completing, and deleting reminders.
- Fetching pet-care tips.
- Saving and unsaving a tip.
- Persistence between database connections or requests.
- Appropriate behaviour for invalid requests and nonexistent records.

Run the tests and fix failures.

### API integration tests

Start the real development server and make actual HTTP requests to the implemented endpoints. Confirm that responses match the documented API contract and that created data can be fetched back from SQLite.

Do not rely only on mocked API responses to claim that the backend works.

### iOS build checks

Use the existing Xcode project and scheme. Inspect the build settings and available destinations before selecting build commands.

- Build the iOS application.
- Fix all compile-time errors and warnings that you introduce.
- Confirm that every required source file is part of the app target.
- Verify correct API request and response decoding.
- Add tests for important ViewModel or service logic where practical.
- Launch the app in an available simulator and exercise the key screens when possible.

My current terminal previously reported that `xcrun simctl list devices available` returned an empty device list. Recheck this instead of assuming a simulator is available. If none is available, perform the strongest build and API tests possible, report the simulator limitation, and tell me the exact Xcode steps needed to install a compatible iOS Simulator runtime and device.

### End-to-end acceptance checklist

Verify the following sequence wherever the available environment allows it:

1. Start the backend and confirm that `/health` returns a successful response.
2. Launch PawPal and see onboarding when no pet exists.
3. Create a pet and verify the stored record using the API.
4. Relaunch or refresh the app and verify that the pet is fetched from the backend.
5. Create a care activity and verify it appears in the activity history and dashboard.
6. Create a reminder and verify it persists in the database.
7. Mark the reminder as completed and verify the backend reflects the change.
8. Delete a reminder and verify the backend record is removed.
9. View pet tips and save or unsave one.
10. Restart the backend and app and confirm persisted information remains available.
11. Stop the backend temporarily and confirm that PawPal shows a clear connection error with a retry action rather than crashing or displaying fake success.
12. Confirm the CleverTap training directory remains separate and the main application builds without CleverTap.

If a test cannot be completed because a simulator, physical device, account, credential, or permission is unavailable, state exactly what blocked it. Do not mark blocked tests as passed.

## 10. Simple developer experience

Make it easy for me to run everything.

Create a backend setup script that:

- Creates a Python virtual environment if needed.
- Installs the declared dependencies.
- Starts the FastAPI server.
- Does not overwrite my system Python or unrelated environment files.

Provide a short, reliable set of terminal commands for starting the backend and running tests. The iOS app should be buildable and runnable from Xcode without CocoaPods or Homebrew.

Use relative paths where possible. Do not hardcode my Mac username into application code.

Use a `.gitignore` for Python virtual environments, generated SQLite database files, caches, local secrets, and build artifacts. Never place credentials in source code.

Do not add external dependencies unless they provide a clear benefit.

## 11. Final report — required output from you

After implementation and verification, give me a clear report with these sections:

**A. What you built**

Summarize the screens, backend, database, API, and local notification functionality.

**B. Folder structure**

Show the actual project structure. Identify the main PawPal root and the separate full path to `Pawpal_int`.

**C. MVVM file classification**

Provide a table listing each important file, its path, whether it is a Model, View, ViewModel, Service, Utility, or Backend file, and a one-line explanation of its purpose.

**D. How to run**

Give me the exact commands to start the backend, run its tests, and launch the app in Xcode.

**E. API verification**

List the endpoints checked and whether each relevant test passed.

**F. Test results**

Report the actual iOS build results, backend test results, API integration results, simulator launch results, and any untested or blocked checks. Be specific.

**G. CleverTap training roadmap**

Explain what files exist in each `Pawpal_int` phase, what each phase teaches, which files I will later copy or adapt, and what dashboard or Apple configuration will be required.

**H. Remaining issues**

List any unresolved issues, missing dependencies, environmental blockers, or future work. Do not hide failures.

**I. Confirmation of separation**

Confirm the result of checking the main app for CleverTap imports, packages, configuration, and source files, and confirm that the existing FocusFlow and QueueUp projects were not modified.

## Final instruction

Start by inspecting the current workspace and reference integration folders. Then implement the project in manageable steps, verify the important flows, and fix any errors you find.

Make reasonable implementation decisions without asking me unnecessary questions. Keep the app and backend beginner-friendly, maintain a consistent naming convention, and explain the code as you go.

**Correctness and verified functionality are more important than finishing quickly. Never claim that the app works end-to-end unless the relevant flows were actually tested.**