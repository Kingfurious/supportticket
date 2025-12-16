# Support Ticket System - Backend Server

Node.js REST API server for the Support Ticket System.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Configure Firebase Admin SDK:

### Option 1: Service Account Key (Recommended)
1. Go to Firebase Console > Project Settings > Service Accounts
2. Click "Generate new private key"
3. Save the JSON file in the server directory
4. Update `index.js` to use the service account key:
```javascript
const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});
```

### Option 2: Application Default Credentials
For local development, you can use:
```bash
gcloud auth application-default login
```
Or set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable.

3. Create `.env` file (optional):
```bash
cp .env.example .env
# Edit .env with your settings
```

## Running the Server

Development mode (with auto-reload):
```bash
npm run dev
```

Production mode:
```bash
npm start
```

Server will run on `http://localhost:3000` by default.

## API Endpoints

All ticket endpoints require Firebase ID token in the Authorization header:
```
Authorization: Bearer <firebase-id-token>
```

### Health Check
- `GET /health` - Check if server is running

### Tickets
- `POST /api/tickets` - Create a new ticket
  - Body: `{ "title": "string", "description": "string" }`
  
- `GET /api/tickets` - Get all tickets for the logged-in user

- `GET /api/tickets/:id` - Get ticket details by ID

- `PATCH /api/tickets/:id/status` - Update ticket status
  - Body: `{ "status": "Open" | "In Progress" | "Closed" }`

## Firestore Collection Structure

### Collection: `tickets`

Document structure:
```json
{
  "id": "auto-generated-doc-id",
  "userId": "firebase-user-id",
  "title": "Ticket title",
  "description": "Ticket description",
  "status": "Open" | "In Progress" | "Closed",
  "createdAt": "Firestore Timestamp",
  "updatedAt": "Firestore Timestamp" (optional)
}
```

