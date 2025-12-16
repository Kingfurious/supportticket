const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Initialize Firebase Admin SDK
let db;
try {
  const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');
  
  // Check if Firebase Admin is already initialized
  if (admin.apps.length === 0) {
    // Try to use service account key if it exists (recommended)
    if (fs.existsSync(serviceAccountPath)) {
      const serviceAccount = require(serviceAccountPath);
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
      });
      console.log('✅ Firebase Admin initialized with service account key');
    } else {
      // Fallback: Try using project ID (requires application default credentials)
      console.log('⚠️  Service account key not found. Trying application default credentials...');
      admin.initializeApp({
        projectId: 'attendance-8a192', // From firebase_options.dart
      });
      console.log('✅ Firebase Admin initialized with project ID');
    }
  }
  
  db = admin.firestore();
  console.log('✅ Firestore database initialized');
} catch (error) {
  console.error('❌ Error initializing Firebase Admin:', error.message);
  console.error('Error details:', error);
  console.log('\n⚠️  IMPORTANT: Firebase Admin must be initialized to use Firestore!');
  console.log('\n📖 Setup Instructions:');
  console.log('\nOption 1: Use Service Account Key (Recommended - Easiest)');
  console.log('  1. Go to Firebase Console: https://console.firebase.google.com/');
  console.log('  2. Select project: attendance-8a192');
  console.log('  3. Go to Project Settings > Service Accounts');
  console.log('  4. Click "Generate new private key"');
  console.log('  5. Save the JSON file as "serviceAccountKey.json" in:', __dirname);
  console.log('\nOption 2: Use Application Default Credentials');
  console.log('  Run: gcloud auth application-default login');
  console.log('  Or set GOOGLE_APPLICATION_CREDENTIALS environment variable');
  console.log('\nSee SETUP_FIREBASE.md for detailed instructions.\n');
  process.exit(1); // Exit if Firebase Admin fails to initialize
}

// Middleware
app.use(cors()); // Enable CORS for Flutter app
app.use(express.json()); // Parse JSON request bodies

// Middleware to verify Firebase ID token
async function verifyToken(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Unauthorized: No token provided' });
    }

    const idToken = authHeader.split('Bearer ')[1];
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    
    // Attach user info to request object
    req.user = {
      uid: decodedToken.uid,
      email: decodedToken.email,
    };
    
    next();
  } catch (error) {
    console.error('Error verifying token:', error);
    return res.status(401).json({ error: 'Unauthorized: Invalid token' });
  }
}

// Routes

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Server is running' });
});

// Create a new ticket
app.post('/api/tickets', verifyToken, async (req, res) => {
  try {
    const { title, description } = req.body;
    const userId = req.user.uid;

    // Validate input
    if (!title || !description) {
      return res.status(400).json({ 
        error: 'Title and description are required' 
      });
    }

    if (title.trim().length < 5) {
      return res.status(400).json({ 
        error: 'Title must be at least 5 characters' 
      });
    }

    if (description.trim().length < 10) {
      return res.status(400).json({ 
        error: 'Description must be at least 10 characters' 
      });
    }

    // Create ticket document
    const ticketData = {
      userId,
      title: title.trim(),
      description: description.trim(),
      status: 'Open', // Default status
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    const docRef = await db.collection('tickets').add(ticketData);
    
    // Fetch the created ticket with ID
    const ticketDoc = await docRef.get();
    const ticket = {
      id: ticketDoc.id,
      ...ticketDoc.data(),
      createdAt: ticketDoc.data().createdAt?.toDate().toISOString() || new Date().toISOString(),
    };

    res.status(201).json(ticket);
  } catch (error) {
    console.error('Error creating ticket:', error);
    console.error('Error stack:', error.stack);
    // In development, always show detailed error messages for debugging
    const isDevelopment = !process.env.NODE_ENV || process.env.NODE_ENV === 'development';
    res.status(500).json({ 
      error: 'Internal server error',
      message: isDevelopment ? error.message : undefined,
      details: isDevelopment ? error.stack : undefined
    });
  }
});

// Get all tickets for the logged-in user
app.get('/api/tickets', verifyToken, async (req, res) => {
  try {
    const userId = req.user.uid;

    // Query tickets for this user (without orderBy to avoid index requirement)
    const ticketsSnapshot = await db
      .collection('tickets')
      .where('userId', '==', userId)
      .get();

    // Convert to array and sort by createdAt in memory (newest first)
    const tickets = ticketsSnapshot.docs
      .map((doc) => {
        const data = doc.data();
        return {
          id: doc.id,
          ...data,
          createdAt: data.createdAt?.toDate().toISOString() || new Date().toISOString(),
        };
      })
      .sort((a, b) => {
        // Sort by createdAt descending (newest first)
        const dateA = new Date(a.createdAt);
        const dateB = new Date(b.createdAt);
        return dateB.getTime() - dateA.getTime();
      });

    res.json(tickets);
  } catch (error) {
    console.error('Error fetching tickets:', error);
    console.error('Error stack:', error.stack);
    const isDevelopment = !process.env.NODE_ENV || process.env.NODE_ENV === 'development';
    res.status(500).json({ 
      error: 'Internal server error',
      message: isDevelopment ? error.message : undefined
    });
  }
});

// Get ticket details by ID
app.get('/api/tickets/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.uid;

    const ticketDoc = await db.collection('tickets').doc(id).get();

    if (!ticketDoc.exists) {
      return res.status(404).json({ error: 'Ticket not found' });
    }

    const ticketData = ticketDoc.data();

    // Verify that the ticket belongs to the user
    if (ticketData.userId !== userId) {
      return res.status(403).json({ error: 'Forbidden: Access denied' });
    }

    const ticket = {
      id: ticketDoc.id,
      ...ticketData,
      createdAt: ticketData.createdAt?.toDate().toISOString() || new Date().toISOString(),
    };

    res.json(ticket);
  } catch (error) {
    console.error('Error fetching ticket:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update ticket status (optional endpoint)
app.patch('/api/tickets/:id/status', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const userId = req.user.uid;

    // Validate status
    const validStatuses = ['Open', 'In Progress', 'Closed'];
    if (!status || !validStatuses.includes(status)) {
      return res.status(400).json({ 
        error: `Status must be one of: ${validStatuses.join(', ')}` 
      });
    }

    const ticketDoc = await db.collection('tickets').doc(id).get();

    if (!ticketDoc.exists) {
      return res.status(404).json({ error: 'Ticket not found' });
    }

    const ticketData = ticketDoc.data();

    // Verify that the ticket belongs to the user
    if (ticketData.userId !== userId) {
      return res.status(403).json({ error: 'Forbidden: Access denied' });
    }

    // Update ticket status
    await db.collection('tickets').doc(id).update({
      status,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Fetch updated ticket
    const updatedDoc = await db.collection('tickets').doc(id).get();
    const ticket = {
      id: updatedDoc.id,
      ...updatedDoc.data(),
      createdAt: updatedDoc.data().createdAt?.toDate().toISOString() || new Date().toISOString(),
    };

    res.json(ticket);
  } catch (error) {
    console.error('Error updating ticket status:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});

