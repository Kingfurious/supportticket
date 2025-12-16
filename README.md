# Support Ticket System

A full-stack support ticket/helpdesk system built with Flutter (frontend) and Node.js (backend), using Firebase for authentication and Firestore for data storage.

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Node.js (Express.js)
- **Authentication**: Firebase Authentication
- **Database**: Firebase Firestore
- **API**: REST API

## Project Structure

```
.
├── supportticket/          # Flutter frontend application
│   ├── lib/
│   │   ├── config/        # Configuration files
│   │   ├── models/        # Data models
│   │   ├── screens/       # UI screens
│   │   ├── services/      # Business logic services
│   │   └── main.dart      # App entry point
│   └── pubspec.yaml       # Flutter dependencies
│
└── backend/               # Node.js backend server
    └── server/
        ├── index.js       # Express server
        ├── package.json   # Node.js dependencies
        └── README.md      # Backend documentation
```

## Features

### Authentication
- User signup with email and password
- User login with email and password
- Proper error handling for authentication failures
- Session management (maintains login state)

### Ticket Management
- Create new support tickets with title and description
- View all tickets created by the logged-in user
- View detailed ticket information
- Ticket status tracking (Open, In Progress, Closed)
- Status badges with visual distinction

### Dashboard
- Summary statistics (total tickets, open, in progress, closed)
- Quick navigation to create tickets or view ticket list

## Setup Instructions

### Prerequisites

1. **Flutter SDK** (>=3.9.2)
2. **Node.js** (>=14.x)
3. **npm** or **yarn**
4. **Firebase Project** with:
   - Authentication enabled (Email/Password provider)
   - Firestore Database created

### Backend Setup

1. Navigate to backend directory:
```bash
cd backend/server
```

2. Install dependencies:
```bash
npm install
```

3. Configure Firebase Admin SDK:

   **Option 1: Service Account Key (Recommended)**
   - Go to Firebase Console > Project Settings > Service Accounts
   - Click "Generate new private key"
   - Save the JSON file in the `backend/server` directory
   - Update `index.js` to use the service account key

   **Option 2: Application Default Credentials**
   ```bash
   gcloud auth application-default login
   ```

4. Start the server:
```bash
npm run dev  # Development mode with auto-reload
# or
npm start    # Production mode
```

The server will run on `http://localhost:3000` by default.

### Frontend Setup

1. Navigate to Flutter app directory:
```bash
cd supportticket
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure API base URL:

   Edit `lib/config/api_config.dart`:
   - **Android Emulator**: `http://10.0.2.2:3000/api`
   - **iOS Simulator**: `http://localhost:3000/api`
   - **Physical Device**: `http://<your-computer-ip>:3000/api`

4. Run the app:
```bash
flutter run
```

## Firebase Configuration

The Firebase project ID is: `attendance-8a192`

### Required Firebase Setup:

1. **Enable Authentication**:
   - Go to Firebase Console > Authentication
   - Enable "Email/Password" sign-in method

2. **Create Firestore Database**:
   - Go to Firebase Console > Firestore Database
   - Create database in production mode (or test mode for development)
   - Set up security rules (see below)

3. **Firestore Security Rules** (for development/testing):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Tickets collection: users can only read/write their own tickets
    match /tickets/{ticketId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }
  }
}
```

## API Endpoints

All ticket endpoints require Firebase ID token in the Authorization header:
```
Authorization: Bearer <firebase-id-token>
```

- `GET /health` - Health check
- `POST /api/tickets` - Create a new ticket
- `GET /api/tickets` - Get all tickets for the logged-in user
- `GET /api/tickets/:id` - Get ticket details by ID
- `PATCH /api/tickets/:id/status` - Update ticket status

## Data Model

### Ticket Document Structure

```json
{
  "id": "auto-generated-doc-id",
  "userId": "firebase-user-id",
  "title": "Ticket title",
  "description": "Ticket description",
  "status": "Open" | "In Progress" | "Closed",
  "createdAt": "ISO timestamp",
  "updatedAt": "ISO timestamp" (optional)
}
```

## Screens

1. **Login Screen**: User authentication
2. **Signup Screen**: New user registration
3. **Dashboard**: Overview with statistics and navigation
4. **Create Ticket Screen**: Form to create new tickets
5. **Ticket List Screen**: List all user's tickets with status badges
6. **Ticket Detail Screen**: Full ticket information

## Development Notes

- The project is designed to be beginner-friendly with clear structure
- All code includes comments for learning purposes
- Form validation with user-friendly error messages
- Status badges with clear visual distinction
- Proper error handling throughout

## Troubleshooting

### Backend Issues

1. **Firebase Admin initialization error**:
   - Ensure you have valid Firebase credentials
   - Check that the project ID matches your Firebase project
   - Verify service account key file path if using Option 1

2. **CORS errors**:
   - CORS is enabled for all origins in development
   - For production, configure CORS properly in `index.js`

### Frontend Issues

1. **API connection errors**:
   - Verify the API base URL in `lib/config/api_config.dart`
   - Ensure backend server is running
   - For physical devices, use your computer's IP address instead of localhost

2. **Firebase initialization errors**:
   - Verify `firebase_options.dart` is correctly configured
   - Ensure Firebase project has Authentication and Firestore enabled

## License

This is a training project for learning purposes.

