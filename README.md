# Smart Student Planner Mobile Application 

## Group Members

**Group Name**: Papoi

**Section**: 1

**Group Members** :
- Nur Adriana Karmila Binti Nasharuddin - 2312298
- Mutsanna Bin Zulkefle - 238061
- Izyan Ilyani Binti Rodzuan - 2315464
- Syarifah Aliyyah Fasha binti Syed Ahmad Iqbal - 2319130

## 👥 Team Roles

| Team Member | Role |
|------------|------|
| Nur Adriana Karmila | Login & Register |
| Syarifah Aliyyah Fasha | Dashboard |
| Mutsanna | Assignment & Timetable |
| Izyan Ilyani | Notes & Profile |

## Project Title
**StudySync - Smart Student Planner**

# Introduction
University students often face difficulties in managing assignments, class schedules, study reminders, and academic activities efficiently. They often rely on multiple applications or manual notes[...]

StudySync is a smart student planner mobile application developed using Flutter and Firebase. The application aims to provide students with a centralized platform to manage academic tasks, schedul[...]

The project is designed to improve student productivity, enhance time management skills, and simplify academic planning through a modern mobile application. The app also promotes efficient learnin[...]

# Objectives
- To develop a mobile application for managing academic tasks and schedules.
- To help students organize assignments and deadlines efficiently.
- To provide reminder notifications for important academic activities.
- To improve student productivity and time management skills.
- To implement Firebase services for real-time data storage and authentication.
- To create a simple, modern, and user-friendly mobile application using Flutter.

# Target Users
**Primary Users**
- University students

**Secondary Users**
- Tutors
- Academic advisors
# Features & Functionalities
Below is a detailed breakdown of the core features and functionalities that will be implemented in the Student Planner application:
| Feature | Description |
|---|---|
| User Authentication | Users can register, login and logout securely using Firebase Authentication |
| Dashboard | Displays task summary, reminders and productivity overview |
| Task Manager | Users can add, edit, delete and mark assignments/tasks as completed |
| Timetable Management | Students can organize weekly class schedules |
| Notes Module | Users can create and manage study notes by subject |
| Reminder Notifications | Deadline and study reminders using local notifications |
| Academic Progress Tracker | Tracks completed tasks and study productivity |
| Profile Management | Users can update profile information |
| Dark Mode | Optional dark theme for better user experience |
| Search Function | Search for tasks, schedules or notes quickly |

# UI Mockups
1. Log in Page 
<img width="108" height="192" alt="Log in" src="https://github.com/user-attachments/assets/b3ea2044-b30c-48ec-9351-06b22a8754e5" />
   
2. Dashboard
<img width="108" height="192" alt="Home Dashboard" src="https://github.com/user-attachments/assets/a30bc764-43aa-4559-9004-161286060919" />
   
3. Assignment Tracker
<img width="108" height="192" alt="Assignment Tracker" src="https://github.com/user-attachments/assets/254e796b-8b4e-48f3-a0b9-a6f99bed0b5c" />
   
4. Timetable
<img width="108" height="192" alt="Timetable" src="https://github.com/user-attachments/assets/151c147c-ad2d-4e78-a6ba-c35d8bcfbe05" />

5. Notes
<img width="108" height="192" alt="Note" src="https://github.com/user-attachments/assets/88770daa-51f4-493e-a020-312638716a4f" />

# Architecture / Technical Design

## System Architecture

StudySync is developed using the Flutter framework with Firebase as the backend service provider. The application follows a modular architecture approach to ensure maintainability, scalability, an[...]

The application consists of three main layers:

1. Presentation Layer (UI)
2. Business Logic Layer
3. Data Layer (Firebase)

---

## Architecture Overview

```plaintext
+---------------------------------------------------+
|                 Presentation Layer                |
|---------------------------------------------------|
|  Login Screen | Dashboard | Tasks | Notes | UI    |
+---------------------------------------------------+
                      ↓
+---------------------------------------------------+
|               Business Logic Layer                |
|---------------------------------------------------|
| Provider State Management | Controllers | Logic   |
+---------------------------------------------------+
                      ↓
+---------------------------------------------------+
|                    Data Layer                     |
|---------------------------------------------------|
| Firebase Authentication | Firestore | Storage     |
+---------------------------------------------------+
```

---

## Technologies Used

| Technology                  | Purpose                        |
| --------------------------- | ------------------------------ |
| Flutter                     | Mobile application development |
| Dart                        | Programming language           |
| Firebase Authentication     | User login and registration    |
| Cloud Firestore             | Real-time database             |
| Provider                    | State management               |
| go_router                   | Navigation and routing         |
| flutter_local_notifications | Reminder notifications         |

---

## State Management

The application uses **Provider** as the state management solution.

Provider is chosen because:

* lightweight and beginner-friendly
* easy to manage application states
* suitable for modular Flutter applications
* simplifies communication between UI and backend services

Provider manages:

* user authentication state
* task updates
* note management
* timetable updates
* app theme settings

---

## Navigation Structure

The application uses named routes or `go_router` for navigation between screens.

### Main Navigation Flow

```plaintext
Splash Screen
      ↓
Login/Register
      ↓
Dashboard
 ├── Task Manager
 ├── Timetable
 ├── Notes
 ├── Progress Tracker
 └── Profile
```

---

## Module Structure

The application is divided into several modules:

### 1. Authentication Module

Responsible for:

* user registration
* login/logout
* session management

### 2. Dashboard Module

Responsible for:

* displaying productivity overview
* showing upcoming deadlines
* quick navigation

### 3. Task Management Module

Responsible for:

* CRUD operations for tasks
* assignment tracking
* task completion status

### 4. Timetable Module

Responsible for:

* managing class schedules
* organizing weekly timetable

### 5. Notes Module

Responsible for:

* creating and editing study notes
* organizing notes by subject

### 6. Notification Module

Responsible for:

* assignment reminders
* study alerts
* deadline notifications

---

## Firebase Integration

The application integrates Firebase services:

### Firebase Authentication

Used for:

* username/password login
* user registration
* secure authentication

### Cloud Firestore

Used for:

* storing tasks
* storing notes
* storing schedules
* storing user information

### Local Notifications

Used for:

* assignment deadline reminders
* study session alerts

---

## Project Folder Structure

```plaintext
lib/
├── models/
├── providers/
├── services/
├── screens/
├── widgets/
├── utils/
└── routes/
├── main.dart
```

### Folder Description

| Folder    | Function                   |
| --------- | -------------------------- |
| models    | Data models/classes        |
| providers | State management classes   |
| services  | Firebase and API services  |
| screens   | Application pages/screens  |
| widgets   | Reusable UI components     |
| utils     | Helper functions/utilities |
| routes    | Navigation configuration   |

---

## UI Design Approach

The application follows Material Design 3 principles with:

* responsive layouts
* consistent color schemes
* clean typography
* user-friendly navigation
* minimalist interface design

The UI is designed to provide a simple and efficient user experience for students.

---

## Security Considerations

The application implements:

* Firebase secure authentication
* authenticated user access
* protected Firestore data
* input validation for forms

---

## Scalability

The modular architecture allows future enhancements such as:

* cloud synchronization
* AI study assistant
* calendar integration
* group study collaboration
* attendance tracking


# Data Model

The application will utilize Firebase's Cloud Firestore, a NoSQL document database to store and manage data. The database is organized into four primary collections to efficiently handle user inf[...]

#### Users Collection
Stores authentication details and basic profile information for registered students.

| Field | Type | Description |
|---|---|---|
| userId | String | Unique identifier for the user |
| name | String | The student's full name |
| email | String | The student's registered email address |

#### Tasks Collection
Manages all assignments, to-do lists, and academic deadlines.

| Field | Type | Description |
|---|---|---|
| taskId | String | Unique identifier for the specific task |
| title | String | The title or name of the assignment |
| description | String | Detailed information or instructions regarding the task |
| deadline | Timestamp | The exact date and time the task is due |
| status | Boolean | Tracks completion (e.g., true for completed, false for pending) |

#### Schedules Collection
Maintains the student's weekly timetable and recurring classes.

| Field | Type | Description |
|---|---|---|
| scheduleId | String | Unique identifier for the timetable entry |
| subject | String | The name of the class, course, or subject |
| day | String | The day of the week the class occurs |
| time | String | The start and end time of the class |

#### Notes Collection
Stores the user's personal study notes and academic materials.

| Field | Type | Description |
|---|---|---|
| noteId | String | Unique identifier for the specific note |
| subject | String | The subject or category the note belongs to |
| content | String | The main body text/content of the study note |

# Flowchart
<p align="center">
  <img src="Student Planner App Flowchart.png" alt="StudySync System Flowchart" width="850"/>
</p>

### Flowchart Description

The flowchart illustrates the end-to-end architectural logic, navigation paths, and data flows of the **StudySync** mobile application. The system is systematically divided into four structural layers and functional modules:

#### 1. Authentication Module & Session Management
* **Session Lifecycle Check:** Upon launching, the app triggers a `Splash Screen` where it evaluates the current user authentication state via Provider.
* **Conditional Routing:** If an active user session exists (`Is User Logged In? → Yes`), the user bypasses the login portal entirely and routes directly to the Dashboard. 
* **Auth Validation Loop:** New or unauthenticated users must navigate through registration or login actions. The credentials undergo an verification loop with **Firebase Auth**. Failed validation surfaces an error handling block (`Show Validation Error`), routing the user safely back to the inputs, while a successful validation grants gateway passage.

#### 2. Centralized Dashboard Module
* Once authenticated, users land on the main `Dashboard` hub. This interface aggregates structural data views, providing task summaries, real-time reminders, and productivity metrics fetched globally from the backend state. It serves as the primary router to all core feature modules.

#### 3. Core Feature Modules (Presentation Layer CRUD)
The application handles user interactions across distinct functional sub-modules:
* **Task Manager:** Directs users to task mutations. It splits into separate logical branches depending on the intended user action, which are processing text entries for typical `Create/Update/Delete` operations, or executing a state toggle boolean for marking assignments as `Completed`.
* **Timetable & Notes:** Handles operational requests to alter weekly schedules or update subject-specific study notes.

#### 4. Data Layer Sync & Background Notification Services
* **Persistent Storage Pipelines:** All successful user CRUD mutations across tasks, schedules, and notes feed directly down into individual stream vectors targeting the **Cloud Firestore NoSQL DB**.
* **Reactive Event Triggers:** The data layer continuously listens for updates. When a task deadline approaches or an academic event updates (`Deadline Check / Event Updated? → Yes`), it hooks into the local background services subsystem.
* **Notification Execution:** This updates state and forces a trigger via the `flutter_local_notifications` package, pushing a local alert directly onto the user's mobile device interface.

#### 5. Session Exits
* When a user initiates a sign-out event from their profile, the app fires a `Trigger Logout` routine. It instructs the application state provider to purge all active local user tokens, clear cached credential configurations, and dynamically pop the navigation stack back to the root `Login / Register` terminal screen.

# References
- Flutter Documentation
https://docs.flutter.dev
- Firebase Documentation
https://firebase.google.com/docs
- Provider Package
https://pub.dev/packages/provider
- Flutter Local Notifications
https://pub.dev/packages/flutter_local_notifications
- go_router Package
https://pub.dev/packages/go_router
- Material Design 3
https://m3.material.io
- Cloud Firestore Documentation
https://firebase.google.com/docs/firestore
