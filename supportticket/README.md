# Support Ticket System - Flutter App

Flutter frontend application for the Support Ticket System.

## Setup

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Configure API base URL:

Edit `lib/config/api_config.dart` and update the `baseUrl` based on your environment:

- **Android Emulator**: `http://10.0.2.2:3000/api`
- **iOS Simulator**: `http://localhost:3000/api`
- **Physical Device**: `http://<your-computer-ip>:3000/api` (e.g., `http://192.168.1.100:3000/api`)
- **Production**: Your production API URL

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── config/
│   └── api_config.dart          # API configuration
├── models/
│   └── ticket.dart              # Ticket data model
├── screens/
│   ├── login_screen.dart        # Login screen
│   ├── signup_screen.dart       # Signup screen
│   ├── dashboard_screen.dart    # Dashboard with summary
│   ├── create_ticket_screen.dart # Create new ticket
│   ├── ticket_list_screen.dart  # List all tickets
│   └── ticket_detail_screen.dart # Ticket details
├── services/
│   ├── auth_service.dart        # Firebase Authentication service
│   └── ticket_service.dart      # Ticket API service
└── main.dart                    # App entry point
```

## Features

- **Authentication**: Firebase Auth with email/password
- **Dashboard**: Overview of ticket statistics
- **Create Tickets**: Create new support tickets
- **View Tickets**: List all tickets with status badges
- **Ticket Details**: View full ticket information

## Dependencies

- `firebase_core`: Firebase SDK initialization
- `firebase_auth`: Firebase Authentication
- `http`: HTTP client for API calls

## Firebase Configuration

Firebase is configured using `firebase_options.dart` which is automatically generated. The project ID is: `attendance-8a192`

Make sure:
1. Firebase Authentication is enabled in Firebase Console
2. Email/Password authentication method is enabled
3. Firestore Database is created and rules are configured
