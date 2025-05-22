// controllers/finance.controller.js
const pool = require('../database');

// Helper function for consistent ID handling
const formatPaymentResponse = (payment) => ({
  payment_id: payment.payment_id?.toString(),
  household_id: payment.household_id?.toString(),
  apartment_id: payment.apartment_id?.toString(),
  payment_type: payment.payment_type,
  amount: parseFloat(payment.amount),
  due_date: payment.due_date,
  payment_date: payment.payment_date,
  status: payment.status,
  notes: payment.notes,
  apartment_number: payment.apartment_number
});

// --- Payment Management (UC-07 Manage Compulsory Fees) ---
exports.createPayment = async (req, res, next) => {
  const { household_id, payment_type, amount, due_date, payment_date, status = 'Unpaid' } = req.body;

  if (!household_id || !payment_type || amount === undefined || !due_date) {
    return res.status(400).json({ message: 'Household ID, payment type, amount, and due date are required by controller.' });
  }
  if (isNaN(parseFloat(amount)) || parseFloat(amount) <= 0) {
      return res.status(400).json({ message: 'Amount must be a positive number.' });
  }

  try {
    // Check if household exists
    const [householdExists] = await pool.query('SELECT household_id FROM Households WHERE household_id = ?', [household_id]);
    if (householdExists.length === 0) {
        return res.status(404).json({ message: 'Household not found.' });
    }

    const [result] = await pool.query(
      'INSERT INTO Payments (household_id, payment_type, amount, due_date, payment_date, status) VALUES (?, ?, ?, ?, ?, ?)',
      [household_id, payment_type, parseFloat(amount), due_date, payment_date, status]
    );
    
    // Fetch the created payment to return consistent format
    const [newPayment] = await pool.query(`
      SELECT p.*, h.apartment_id, a.apartment_number
      FROM Payments p
      LEFT JOIN Households h ON p.household_id = h.household_id
      LEFT JOIN Apartments a ON h.apartment_id = a.apartment_id
      WHERE p.payment_id = ?
    `, [result.insertId]);
    
    res.status(201).json(formatPaymentResponse(newPayment[0]));
  } catch (error) {
    next(error);
  }
};

exports.getPaymentsByHousehold = async (req, res, next) => {
  const { household_id } = req.params;
  try {
    // Check if household exists
    const [householdExists] = await pool.query('SELECT household_id FROM Households WHERE household_id = ?', [household_id]);
    if (householdExists.length === 0) {
        return res.status(404).json({ message: 'Household not found.' });
    }
    
    const [payments] = await pool.query(`
      SELECT p.*, h.apartment_id, a.apartment_number
      FROM Payments p
      LEFT JOIN Households h ON p.household_id = h.household_id
      LEFT JOIN Apartments a ON h.apartment_id = a.apartment_id
      WHERE p.household_id = ?
      ORDER BY p.due_date DESC
    `, [household_id]);
    
    res.json(payments.map(formatPaymentResponse));
  } catch (error) {
    next(error);
  }
};

exports.getAllPayments = async (req, res, next) => {
  const { status, startDate, endDate, householdId } = req.query;
  let query = `
    SELECT p.*, h.apartment_id, a.apartment_number
    FROM Payments p
    LEFT JOIN Households h ON p.household_id = h.household_id
    LEFT JOIN Apartments a ON h.apartment_id = a.apartment_id
    WHERE 1=1
  `;
  const queryParams = [];

  if (status) {
    query += ' AND p.status = ?';
    queryParams.push(status);
  }
  if (startDate) {
    query += ' AND p.due_date >= ?';
    queryParams.push(startDate);
  }
  if (endDate) {
    query += ' AND p.due_date <= ?';
    queryParams.push(endDate);
  }
  if (householdId) {
    query += ' AND p.household_id = ?';
    queryParams.push(householdId);
  }
  query += ' ORDER BY p.due_date DESC, a.apartment_number ASC';

  try {
    const [payments] = await pool.query(query, queryParams);
    res.json(payments.map(formatPaymentResponse));
  } catch (error) {
    next(error);
  }
};

exports.getPaymentById = async (req, res, next) => {
    const { payment_id } = req.params;
    try {
        const query = `
            SELECT p.*, h.apartment_id, a.apartment_number
            FROM Payments p
            LEFT JOIN Households h ON p.household_id = h.household_id
            LEFT JOIN Apartments a ON h.apartment_id = a.apartment_id
            WHERE p.payment_id = ?
        `;
        const [payment] = await pool.query(query, [payment_id]);
        if (payment.length === 0) {
            return res.status(404).json({ message: 'Payment record not found.' });
        }
        res.json(formatPaymentResponse(payment[0]));
    } catch (error) {
        next(error);
    }
};

exports.updatePaymentStatus = async (req, res, next) => {
  const { payment_id } = req.params;
  const { status, payment_date } = req.body;

  if (!status) {
    return res.status(400).json({ message: 'Status is required.' });
  }

  try {
    let paymentDateToUpdate = payment_date;
    if (status === 'Paid' && !payment_date) {
        paymentDateToUpdate = new Date().toISOString().slice(0, 10);
    } else if (status !== 'Paid') {
        paymentDateToUpdate = null;
    }

    const [result] = await pool.query(
      'UPDATE Payments SET status = ?, payment_date = ? WHERE payment_id = ?',
      [status, paymentDateToUpdate, payment_id]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Payment record not found or no change in status.' });
    }

    // Fetch and return updated payment
    const [updatedPayment] = await pool.query(`
      SELECT p.*, h.apartment_id, a.apartment_number
      FROM Payments p
      LEFT JOIN Households h ON p.household_id = h.household_id
      LEFT JOIN Apartments a ON h.apartment_id = a.apartment_id
      WHERE p.payment_id = ?
    `, [payment_id]);
    
    res.json(formatPaymentResponse(updatedPayment[0]));
  } catch (error) {
    next(error);
  }
};

exports.deletePayment = async (req, res, next) => {
    const { payment_id } = req.params;
    try {
        const [result] = await pool.query('DELETE FROM Payments WHERE payment_id = ?', [payment_id]);
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Payment record not found.' });
        }
        res.json({ message: 'Payment record deleted successfully.'});
    } catch (error) {
        next(error);
    }
};


// --- Reporting (UC-04 Send Notification/Report, SRS pg 21) ---
// This is a simplified example. Real reporting would involve more complex queries and possibly dedicated reporting tools.
exports.generateFinancialSummaryReport = async (req, res, next) => {
  const { startDate, endDate } = req.query;

  if (!startDate || !endDate) {
    return res.status(400).json({ message: 'Start date and end date are required for the report.' });
  }

  try {
    const [paidSummary] = await pool.query(
      "SELECT SUM(amount) AS total_collected FROM Payments WHERE status = 'Paid' AND payment_date BETWEEN ? AND ?",
      [startDate, endDate]
    );
    const [dueSummary] = await pool.query(
      "SELECT SUM(amount) AS total_due FROM Payments WHERE due_date BETWEEN ? AND ?",
      [startDate, endDate]
    );
    const [unpaidSummary] = await pool.query(
      "SELECT SUM(amount) AS total_unpaid FROM Payments WHERE status = 'Unpaid' AND due_date <= ?",
      [endDate]
    );

    res.json({
      reportPeriod: { startDate, endDate },
      totalCollected: parseFloat(paidSummary[0].total_collected || 0),
      totalDueInPeriod: parseFloat(dueSummary[0].total_due || 0),
      totalOutstandingUnpaid: parseFloat(unpaidSummary[0].total_unpaid || 0),
    });
  } catch (error) {
    next(error);
  }
};