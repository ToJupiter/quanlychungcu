// server.js
const express = require('express');
const cors = require('cors');
const config = require('./config');
const { errorHandler } = require('./middlewares'); // Import the error handler

// Import routes
const authRoutes = require('./routes/auth.routes');
const managementRoutes = require('./routes/management.routes');
const financeRoutes = require('./routes/finance.routes');
const staffRoutes = require('./routes/staff.routes');

const app = express();

// --- Middlewares ---
// Enable CORS for all origins (adjust for production)
app.use(cors());
// Parse JSON request bodies
app.use(express.json());
// Parse URL-encoded request bodies
app.use(express.urlencoded({ extended: true }));


// --- API Routes ---
app.get('/', (req, res) => {
  res.json({ message: 'Welcome to BlueMoon Apartment Management API!' });
});

app.use('/api/auth', authRoutes);
app.use('/api/management', managementRoutes);
app.use('/api/finance', financeRoutes);
app.use('/api/staff', staffRoutes);


// --- Global Error Handler ---
// This should be the LAST middleware added
app.use(errorHandler);


// --- Start Server ---
const PORT = config.port;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}.`);
  console.log(`Access it at http://localhost:${PORT}`);
});