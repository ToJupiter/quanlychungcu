// routes/auth.routes.js
const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { authenticateToken } = require('../middlewares'); // Assuming you might protect some auth routes

// UC001: Register a new staff member (Potentially protected, only existing admin can do this)
// For simplicity, making it public for initial setup, but in prod this needs protection
// router.post('/register', authenticateToken, authorizeRole(['Admin_BQT']), authController.registerStaff);
router.post('/staff/register', authController.registerStaff); // Public for initial BQT creation

// UC002: Staff Login
router.post('/staff/login', authController.loginStaff);

// UC003: Change Staff Password (Requires authentication)
router.post('/staff/change-password', authenticateToken, authController.changePasswordStaff);

// (Future: Resident login/registration routes would go here if they have direct system access)
// router.post('/resident/register', authController.registerResident);
// router.post('/resident/login', authController.loginResident);

module.exports = router;