// controllers/auth.controller.js
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../database');
const config = require('../config');

// UC001: Staff Registration (by an existing BQT/Admin)
exports.registerStaff = async (req, res, next) => {
  const { full_name, email, phone_number, password, status = 'active' } = req.body;

  if (!full_name || !email || !password) {
    return res.status(400).json({ message: 'Full name, email, and password are required' });
  }

  try {
    // Check if email already exists
    const [existingStaff] = await pool.query('SELECT email FROM Staff WHERE email = ?', [email]);
    if (existingStaff.length > 0) {
      return res.status(409).json({ message: 'Email already in use' });
    }

    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(password, salt);

    const [result] = await pool.query(
      'INSERT INTO Staff (full_name, email, phone_number, password_hash, status) VALUES (?, ?, ?, ?, ?)',
      [full_name, email, phone_number, password_hash, status]
    );

    res.status(201).json({
      message: 'Staff registered successfully',
      staffId: result.insertId,
    });
  } catch (error) {
    next(error);
  }
};

// UC002: Staff Login
exports.loginStaff = async (req, res, next) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required' });
  }

  try {
    const [staffRows] = await pool.query('SELECT staff_id, email, password_hash, status, full_name FROM Staff WHERE email = ?', [email]);
    if (staffRows.length === 0) {
      return res.status(401).json({ message: 'Invalid credentials (email not found)' });
    }

    const staff = staffRows[0];

    if (staff.status !== 'active') {
        return res.status(403).json({ message: 'Account is not active.' });
    }

    const isMatch = await bcrypt.compare(password, staff.password_hash);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials (password incorrect)' });
    }

    // In a real app, add role to payload if you have a roles system
    const payload = {
      staff_id: staff.staff_id,
      email: staff.email,
      name: staff.full_name
      // role: staff.role // example if you have a role column in Staff table
    };

    const token = jwt.sign(payload, config.jwtSecret, { expiresIn: '24h' }); // Token expires in 24 hours

    res.json({
      message: 'Login successful',
      token,
      user: payload // Send back some user info
    });
  } catch (error) {
    next(error);
  }
};

// UC003: Change Password (for authenticated staff)
exports.changePasswordStaff = async (req, res, next) => {
  const { old_password, new_password } = req.body;
  const staff_id = req.user.staff_id; // From authenticateToken middleware

  if (!old_password || !new_password) {
    return res.status(400).json({ message: 'Old password and new password are required' });
  }
  if (new_password.length < 8) {
      return res.status(400).json({ message: 'New password must be at least 8 characters long.'})
  }

  try {
    const [staffRows] = await pool.query('SELECT password_hash FROM Staff WHERE staff_id = ?', [staff_id]);
    if (staffRows.length === 0) {
      return res.status(404).json({ message: 'Staff not found' }); // Should not happen if token is valid
    }

    const staff = staffRows[0];
    const isMatch = await bcrypt.compare(old_password, staff.password_hash);
    if (!isMatch) {
      return res.status(401).json({ message: 'Incorrect old password' });
    }

    const salt = await bcrypt.genSalt(10);
    const new_password_hash = await bcrypt.hash(new_password, salt);

    await pool.query('UPDATE Staff SET password_hash = ? WHERE staff_id = ?', [new_password_hash, staff_id]);

    res.json({ message: 'Password changed successfully' });
  } catch (error) {
    next(error);
  }
};