# Collaborative Todo App

Flutter app with Node.js backend demonstrating platform channels integration and Riverpod.

## Features
- Authentication (JWT)
- CRUD Todos
- Share lists between users
- **Platform Channels:**
  - Native share menu (Android/iOS)
  - Local notifications with custom timing
  - Custom vibration patterns

## Stack
- Frontend: Flutter, Riverpod
- Backend: Node.js, Express, PostgreSQL
- Native: Kotlin (Android), Swift (iOS)

## 🚀 Quick Start

### Backend
```bash
cd backend
npm install
docker-compose up -d  # PostgreSQL
npm run dev
```

### Frontend
```bash
cd mobile
flutter pub get
flutter run
```