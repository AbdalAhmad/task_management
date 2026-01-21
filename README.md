# TaskFlow – Task Management App (Flutter)

TaskFlow is a Flutter-based task management application designed for gig workers.
The app allows users to create, update, delete, and manage tasks efficiently with
authentication, filtering, and a clean Material UI.

This project was developed as part of the **Flutter Developer Intern Assignment for Whatbytes**.

---

## 🚀 Features

### 🔐 User Authentication
- Firebase Authentication (Email & Password)
- User registration and login
- Proper error handling for invalid credentials
- Secure logout functionality

### 📝 Task Management
- Create, edit, delete, and view tasks
- Each task includes:
  - Title
  - Description
  - Due date
  - Priority (Low / Medium / High)
- Mark tasks as completed or incomplete
- Swipe to delete with undo support
- Recently added or edited tasks appear at the top

### 🔍 Task Filtering & Sorting
- Filter tasks by:
  - Priority (Low / Medium / High)
  - Status (Completed / Incomplete)
- Tasks are sorted by **last updated time**
  - Newly added tasks appear at the top
  - Edited tasks also move to the top

### 🎨 User Interface
- Clean and responsive Material UI
- Dark mode support
- Priority-based color indicators
- Optimized for Android and iOS

### 🧠 State Management & Architecture
- Riverpod for state management
- Clean architecture:
  - Presentation layer (UI)
  - Domain layer (Models)
  - Data layer (Providers)

### ☁️ Backend
- Firebase Authentication
- Cloud Firestore for task storage

---

## 🛠️ Tech Stack
- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Riverpod

---

## ▶️ Getting Started

### Prerequisites
- Flutter SDK installed
- Firebase account
- Android Studio / VS Code

### Setup Instructions

1. Clone the repository
   
   git clone https://github.com/AbdalAhmad/task_management.git
