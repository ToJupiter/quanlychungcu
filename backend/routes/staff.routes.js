// routes/staff.routes.js
const express = require('express');
const router = express.Router();
const staffController = require('../controllers/staff.controller');
const { authenticateToken } = require('../middlewares');

// Apply authentication middleware to all routes in this file
router.use(authenticateToken);

// --- Staff Management Routes ---
// GET /api/staff - Get all staff members (with optional filtering)
router.get('/', staffController.getAllStaff);

// GET /api/staff/stats - Get staff statistics
router.get('/stats', staffController.getStaffStats);

// GET /api/staff/:id - Get a single staff member by ID
router.get('/:id', staffController.getStaffById);

// POST /api/staff - Create a new staff member
router.post('/', staffController.createStaff);

// PUT /api/staff/:id - Update a staff member
router.put('/:id', staffController.updateStaff);

// PATCH /api/staff/:id/status - Update staff status (activate/deactivate)
router.patch('/:id/status', staffController.updateStaffStatus);

// PATCH /api/staff/:id/reset-password - Reset staff password (admin function)
router.patch('/:id/reset-password', staffController.resetStaffPassword);

// DELETE /api/staff/:id - Delete (deactivate) a staff member
router.delete('/:id', staffController.deleteStaff);

module.exports = router; 