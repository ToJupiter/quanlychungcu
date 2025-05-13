// routes/finance.routes.js
const express = require('express');
const router = express.Router();
const financeController = require('../controllers/finance.controller');
const { authenticateToken } = require('../middlewares');

// Apply authentication middleware to all routes in this file
router.use(authenticateToken);

// --- Payment Routes ---
// UC-07: Create a new payment record (e.g., compulsory fee)
router.post('/payments', financeController.createPayment);
// GET all payments for a specific household
router.get('/households/:household_id/payments', financeController.getPaymentsByHousehold);
// GET all payments (can be filtered by query params like status, date range)
router.get('/payments', financeController.getAllPayments);
// GET a single payment record by ID
router.get('/payments/:payment_id', financeController.getPaymentById);
// UC-07: Update an existing payment's status (and payment_date if paid)
router.patch('/payments/:payment_id/status', financeController.updatePaymentStatus);
// DELETE a payment record (use with caution)
router.delete('/payments/:payment_id', financeController.deletePayment);


// --- Reporting Routes ---
// UC-04 (SRS pg 21 "Báo cáo và thống kê"): Generate a financial summary report
router.get('/reports/financial-summary', financeController.generateFinancialSummaryReport);
// (More specific reports can be added here)

module.exports = router;