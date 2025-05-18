// middlewares.js
const jwt = require('jsonwebtoken');
const config = require('./config');

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (token == null) {
    return res.status(401).json({ message: 'Unauthorized: No token provided' });
  }

  jwt.verify(token, config.jwtSecret, (err, user) => {
    if (err) {
      return res.status(403).json({ message: 'Forbidden: Token is not valid' });
    }
    req.user = user; // Add user payload to request object (e.g., staff_id, email)
    next();
  });
};

// Basic role check middleware (example)
// You might expand this or create more specific role checks
const authorizeRole = (allowedRoles) => {
  return (req, res, next) => {
    if (!req.user || !req.user.role) { // Assuming 'role' is part of JWT payload
      return res.status(403).json({ message: 'Forbidden: Role information missing' });
    }
    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ message: 'Forbidden: Insufficient permissions' });
    }
    next();
  };
};


const errorHandler = (err, req, res, next) => {
  console.error('Error:', err.message); // Log the error message
  // console.error(err.stack); // Log the full stack trace for debugging

  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';

  res.status(statusCode).json({
    status: 'error',
    statusCode,
    message,
    // ...(process.env.NODE_ENV === 'development' && { stack: err.stack }), // Optionally include stack in dev
  });
};

module.exports = {
  authenticateToken,
  authorizeRole, // Export if you use role-based authorization
  errorHandler,
};