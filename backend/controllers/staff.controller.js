const pool = require('../database');
const bcrypt = require('bcryptjs');

// Helper function for consistent staff response formatting
const formatStaffResponse = (staff) => ({
  staff_id: staff.staff_id?.toString(),
  full_name: staff.full_name,
  email: staff.email,
  phone_number: staff.phone_number,
  status: staff.status,
  created_at: staff.created_at
});

// Get all staff members
exports.getAllStaff = async (req, res, next) => {
  const { status, search } = req.query;
  
  let query = 'SELECT staff_id, full_name, email, phone_number, status, created_at FROM Staff WHERE 1=1';
  const queryParams = [];

  if (status) {
    query += ' AND status = ?';
    queryParams.push(status);
  }

  if (search) {
    query += ' AND (full_name LIKE ? OR email LIKE ? OR phone_number LIKE ?)';
    const searchTerm = `%${search}%`;
    queryParams.push(searchTerm, searchTerm, searchTerm);
  }

  query += ' ORDER BY created_at DESC';

  try {
    const [staff] = await pool.query(query, queryParams);
    res.json(staff.map(formatStaffResponse));
  } catch (error) {
    next(error);
  }
};

// Get staff member by ID
exports.getStaffById = async (req, res, next) => {
  const { id } = req.params;

  try {
    const [staff] = await pool.query(
      'SELECT staff_id, full_name, email, phone_number, status, created_at FROM Staff WHERE staff_id = ?',
      [id]
    );

    if (staff.length === 0) {
      return res.status(404).json({ message: 'Staff member not found' });
    }

    res.json(formatStaffResponse(staff[0]));
  } catch (error) {
    next(error);
  }
};

// Create new staff member
exports.createStaff = async (req, res, next) => {
  const { full_name, email, phone_number, password, status = 'active' } = req.body;

  if (!full_name || !email || !password) {
    return res.status(400).json({ message: 'Full name, email, and password are required' });
  }

  if (password.length < 8) {
    return res.status(400).json({ message: 'Password must be at least 8 characters long' });
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

    // Fetch the created staff to return consistent format
    const [newStaff] = await pool.query(
      'SELECT staff_id, full_name, email, phone_number, status, created_at FROM Staff WHERE staff_id = ?',
      [result.insertId]
    );

    res.status(201).json(formatStaffResponse(newStaff[0]));
  } catch (error) {
    next(error);
  }
};

// Update staff member
exports.updateStaff = async (req, res, next) => {
  const { id } = req.params;
  const { full_name, email, phone_number, status } = req.body;

  if (!full_name || !email) {
    return res.status(400).json({ message: 'Full name and email are required' });
  }

  try {
    // Check if staff exists
    const [existingStaff] = await pool.query('SELECT staff_id FROM Staff WHERE staff_id = ?', [id]);
    if (existingStaff.length === 0) {
      return res.status(404).json({ message: 'Staff member not found' });
    }

    // Check if email is already used by another staff member
    const [emailCheck] = await pool.query('SELECT staff_id FROM Staff WHERE email = ? AND staff_id != ?', [email, id]);
    if (emailCheck.length > 0) {
      return res.status(409).json({ message: 'Email already in use by another staff member' });
    }

    const [result] = await pool.query(
      'UPDATE Staff SET full_name = ?, email = ?, phone_number = ?, status = ? WHERE staff_id = ?',
      [full_name, email, phone_number, status, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Staff member not found' });
    }

    // Fetch and return updated staff
    const [updatedStaff] = await pool.query(
      'SELECT staff_id, full_name, email, phone_number, status, created_at FROM Staff WHERE staff_id = ?',
      [id]
    );

    res.json(formatStaffResponse(updatedStaff[0]));
  } catch (error) {
    next(error);
  }
};

// Update staff status (activate/deactivate)
exports.updateStaffStatus = async (req, res, next) => {
  const { id } = req.params;
  const { status } = req.body;

  if (!status || !['active', 'inactive'].includes(status)) {
    return res.status(400).json({ message: 'Valid status (active or inactive) is required' });
  }

  try {
    const [result] = await pool.query(
      'UPDATE Staff SET status = ? WHERE staff_id = ?',
      [status, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Staff member not found' });
    }

    // Fetch and return updated staff
    const [updatedStaff] = await pool.query(
      'SELECT staff_id, full_name, email, phone_number, status, created_at FROM Staff WHERE staff_id = ?',
      [id]
    );

    res.json(formatStaffResponse(updatedStaff[0]));
  } catch (error) {
    next(error);
  }
};

// Reset staff password (admin function)
exports.resetStaffPassword = async (req, res, next) => {
  const { id } = req.params;
  const { new_password } = req.body;

  if (!new_password) {
    return res.status(400).json({ message: 'New password is required' });
  }

  if (new_password.length < 8) {
    return res.status(400).json({ message: 'Password must be at least 8 characters long' });
  }

  try {
    // Check if staff exists
    const [existingStaff] = await pool.query('SELECT staff_id FROM Staff WHERE staff_id = ?', [id]);
    if (existingStaff.length === 0) {
      return res.status(404).json({ message: 'Staff member not found' });
    }

    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(new_password, salt);

    await pool.query('UPDATE Staff SET password_hash = ? WHERE staff_id = ?', [password_hash, id]);

    res.json({ message: 'Password reset successfully' });
  } catch (error) {
    next(error);
  }
};

// Delete staff member (soft delete by setting status to inactive)
exports.deleteStaff = async (req, res, next) => {
  const { id } = req.params;

  try {
    // Check if staff exists
    const [existingStaff] = await pool.query('SELECT staff_id FROM Staff WHERE staff_id = ?', [id]);
    if (existingStaff.length === 0) {
      return res.status(404).json({ message: 'Staff member not found' });
    }

    // Soft delete by setting status to inactive
    const [result] = await pool.query(
      'UPDATE Staff SET status = ? WHERE staff_id = ?',
      ['inactive', id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Staff member not found' });
    }

    res.json({ message: 'Staff member deactivated successfully' });
  } catch (error) {
    next(error);
  }
};

// Get staff statistics
exports.getStaffStats = async (req, res, next) => {
  try {
    const [totalStaff] = await pool.query('SELECT COUNT(*) as total FROM Staff');
    const [activeStaff] = await pool.query('SELECT COUNT(*) as active FROM Staff WHERE status = "active"');
    const [inactiveStaff] = await pool.query('SELECT COUNT(*) as inactive FROM Staff WHERE status = "inactive"');

    res.json({
      total: totalStaff[0].total,
      active: activeStaff[0].active,
      inactive: inactiveStaff[0].inactive
    });
  } catch (error) {
    next(error);
  }
}; 