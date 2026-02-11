# Collaborative Todo App

A full-stack collaborative task management application built with Flutter and Node.js, featuring real-time list sharing, JWT authentication, and native platform integrations.

## Features

### Core Functionality
- **Authentication** - Secure JWT-based login/register
- **Todo Management** - Full CRUD operations with priorities and due dates
- **List Sharing** - Share lists with other users (read/write permissions)
- **Offline Support** - Local caching with Hive for offline access

### Platform Channels (Native Integration)
- **Native Share Menu** - Share todos via Android/iOS native share sheet
- **Local Notifications** - Custom notification scheduling with native APIs
- **Haptic Feedback** - Custom vibration patterns for interactions

## Tech Stack

### Frontend (Flutter)
| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `dio` | HTTP client |
| `go_router` | Navigation |
| `hive_flutter` | Local storage |
| `flutter_secure_storage` | Secure token storage |
| `connectivity_plus` | Network status |

### Backend (Node.js)
| Package | Purpose |
|---------|---------|
| `express` | Web framework |
| `prisma` | ORM |
| `postgresql` | Database |
| `jsonwebtoken` | JWT authentication |
| `bcrypt` | Password hashing |

### Native
- **Android** - Kotlin
- **iOS** - Swift

## Architecture

```
todoapp/
├── lib/
│   ├── core/                   # Shared utilities
│   │   ├── constants/          # API endpoints, app constants
│   │   ├── di/                 # Dependency injection (providers)
│   │   ├── errors/             # Custom exceptions
│   │   ├── network/            # Network info service
│   │   ├── router/             # GoRouter configuration
│   │   ├── services/           # API service, cache service
│   │   └── theme/              # App theme
│   │
│   ├── data/                   # Data layer
│   │   ├── datasources/
│   │   │   ├── local/          # Hive local storage
│   │   │   └── remote/         # API calls (Dio)
│   │   ├── models/             # JSON serialization models
│   │   └── repositories/       # Repository implementations
│   │
│   ├── domain/                 # Domain layer
│   │   ├── entities/           # Business entities
│   │   └── repositories/       # Repository interfaces
│   │
│   └── features/               # Feature modules
│       ├── auth/               # Authentication
│       ├── lists/              # List management
│       └── todos/              # Todo management
│
backend/
├── src/
│   ├── config/                 # Database config
│   ├── controllers/            # Route handlers
│   ├── middleware/             # Auth middleware
│   └── routes/                 # API routes
├── prisma/                     # Database schema & migrations
└── server.ts                   # Entry point
```

## Getting Started

### Prerequisites
- Flutter SDK 3.27+
- Node.js 22+
- Docker (for PostgreSQL)

### Backend Setup

```bash
# Navigate to backend
cd backend

# Install dependencies
npm install

# Start PostgreSQL container
docker-compose up -d

# Run database migrations
npx prisma migrate dev

# Start development server
npm run dev
```

### Frontend Setup

```bash
# Navigate to Flutter app
cd todoapp

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Environment Variables

Create `backend/.env`:
```env
DATABASE_URL="postgresql://todoapp:dev_password@localhost:5432/todoapp"
JWT_SECRET="your-secret-key"
PORT=3000
```

## API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Register new user |
| POST | `/auth/login` | Login user |

### Lists
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/lists` | Get user's lists |
| POST | `/lists` | Create new list |
| DELETE | `/lists/:id` | Delete list |
| POST | `/lists/:id/shares` | Share list |
| DELETE | `/lists/:id/shares` | Leave shared list |

### Todos
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/todos/:listId` | Get todos for list |
| POST | `/todos` | Create todo |
| PATCH | `/todos/:id` | Update todo |
| DELETE | `/todos/:id` | Delete todo |

## Scripts

### Backend
```bash
npm run dev          # Development with hot reload
npm run build        # Build TypeScript
npm run start        # Production server
npm run lint         # ESLint check
npm run format       # Prettier format
```

### Frontend
```bash
flutter run          # Run app
flutter analyze      # Static analysis
flutter test         # Run tests
dart format .        # Format code
```

## CI/CD

GitHub Actions workflow runs on every push:
- **Backend**: Format check, lint, build
- **Frontend**: Format check, analyze, test

## License

MIT
