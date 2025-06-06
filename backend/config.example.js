// config.example.js
// Copy this file to config.js and update with your actual values

module.exports = {
  // Server configuration
  port: process.env.PORT || 3000,
  
  // JWT secret for token signing (change this to a secure random string)
  jwtSecret: process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-me-in-production',
  
  // Database configuration
  db: {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'your_mysql_username',
    password: process.env.DB_PASSWORD || 'your_mysql_password',
    name: process.env.DB_NAME || 'bluemoon_apartment_db',
    port: process.env.DB_PORT || 3306,
  },
  
  // Environment
  environment: process.env.NODE_ENV || 'development',
  
  // CORS configuration
  cors: {
    origin: process.env.CORS_ORIGIN || ['http://localhost:3000', 'http://localhost:8080'],
    credentials: true,
  },
  
  // Logging configuration
  logging: {
    level: process.env.LOG_LEVEL || 'info',
  },
}; 