// controllers/management.controller.js
const pool = require('../database');

// Helper functions for consistent ID handling
const formatApartmentResponse = (apartment) => ({
  apartment_id: apartment.apartment_id?.toString(),
  apartment_number: apartment.apartment_number,
  area: parseFloat(apartment.area || 0),
  status: apartment.status
});

const formatResidentResponse = (resident) => ({
  resident_id: resident.resident_id?.toString(),
  household_id: resident.household_id?.toString(),
  full_name: resident.full_name,
  date_of_birth: resident.date_of_birth,
  cccd_number: resident.cccd_number,
  role_in_household: resident.role_in_household
});

const formatVehicleResponse = (vehicle) => ({
  vehicle_id: vehicle.vehicle_id?.toString(),
  household_id: vehicle.household_id?.toString(),
  plate_number: vehicle.plate_number,
  vehicle_type: vehicle.vehicle_type,
  registration_date: vehicle.registration_date
});

const formatHouseholdResponse = (household) => ({
  household_id: household.household_id?.toString(),
  apartment_id: household.apartment_id?.toString(),
  apartment_number: household.apartment_number,
  apartment_area: parseFloat(household.apartment_area || 0),
  apartment_status: household.apartment_status,
  head_resident_id: household.head_resident_id?.toString(),
  head_full_name: household.head_full_name,
  head_dob: household.head_dob,
  head_cccd: household.head_cccd,
  move_in_date: household.move_in_date,
  residents: household.residents?.map(formatResidentResponse) || [],
  vehicles: household.vehicles?.map(formatVehicleResponse) || []
});

// --- Apartment Management ---
exports.createApartment = async (req, res, next) => {
  const { apartment_number, area, status } = req.body;
  if (!apartment_number) {
    return res.status(400).json({ message: 'Apartment number is required.' });
  }
  try {
    const [result] = await pool.query(
      'INSERT INTO Apartments (apartment_number, area, status) VALUES (?, ?, ?)',
      [apartment_number, parseFloat(area || 0), status]
    );
    
    // Fetch and return the created apartment
    const [apartment] = await pool.query('SELECT * FROM Apartments WHERE apartment_id = ?', [result.insertId]);
    res.status(201).json(formatApartmentResponse(apartment[0]));
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
        return res.status(409).json({ message: 'Apartment number already exists.' });
    }
    next(error);
  }
};

exports.getAllApartments = async (req, res, next) => {
  try {
    const [apartments] = await pool.query('SELECT * FROM Apartments ORDER BY apartment_number');
    res.json(apartments.map(formatApartmentResponse));
  } catch (error) {
    next(error);
  }
};

exports.getApartmentById = async (req, res, next) => {
    const { id } = req.params;
    try {
        const [apartment] = await pool.query('SELECT * FROM Apartments WHERE apartment_id = ?', [id]);
        if (apartment.length === 0) {
            return res.status(404).json({ message: 'Apartment not found.' });
        }
        res.json(formatApartmentResponse(apartment[0]));
    } catch (error) {
        next(error);
    }
};

exports.updateApartment = async (req, res, next) => {
    const { id } = req.params;
    const { apartment_number, area, status } = req.body;
    if (!apartment_number) {
        return res.status(400).json({ message: 'Apartment number is required.' });
    }
    try {
        const [result] = await pool.query(
            'UPDATE Apartments SET apartment_number = ?, area = ?, status = ? WHERE apartment_id = ?',
            [apartment_number, parseFloat(area || 0), status, id]
        );
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Apartment not found or no changes made.' });
        }
        
        // Fetch and return updated apartment
        const [apartment] = await pool.query('SELECT * FROM Apartments WHERE apartment_id = ?', [id]);
        res.json(formatApartmentResponse(apartment[0]));
    } catch (error) {
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({ message: 'Apartment number already exists for another record.' });
        }
        next(error);
    }
};

exports.deleteApartment = async (req, res, next) => {
    const { id } = req.params;
    try {
        // Check if apartment is linked to a household
        const [households] = await pool.query('SELECT household_id FROM Households WHERE apartment_id = ?', [id]);
        if (households.length > 0) {
            return res.status(400).json({ message: 'Cannot delete apartment. It is linked to one or more households. Please update households first.' });
        }

        const [result] = await pool.query('DELETE FROM Apartments WHERE apartment_id = ?', [id]);
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Apartment not found.' });
        }
        res.status(200).json({ message: 'Apartment deleted successfully.' });
    } catch (error) {
        next(error);
    }
};


// --- Household Management (UC-04 Add Household, UC-06 Search Household) ---
// Combined with Resident Management for creating head of household
exports.createHouseholdWithHead = async (req, res, next) => {
  const { apartment_id, move_in_date, head_full_name, head_date_of_birth, head_cccd_number } = req.body;

  if (!apartment_id || !head_full_name) {
    return res.status(400).json({ message: 'Apartment ID and head of household full name are required.' });
  }

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    // 1. Create Head Resident
    const [residentResult] = await connection.query(
      'INSERT INTO Residents (full_name, date_of_birth, cccd_number, role_in_household) VALUES (?, ?, ?, ?)',
      [head_full_name, head_date_of_birth, head_cccd_number, 'Head']
    );
    const headResidentId = residentResult.insertId;

    // 2. Create Household
    const [householdResult] = await connection.query(
      'INSERT INTO Households (apartment_id, move_in_date, head_of_household_resident_id) VALUES (?, ?, ?)',
      [apartment_id, move_in_date, headResidentId]
    );
    const householdId = householdResult.insertId;

    // 3. Update the created resident with the household_id
    await connection.query('UPDATE Residents SET household_id = ? WHERE resident_id = ?', [householdId, headResidentId]);

    await connection.commit();

    // Fetch the full household details
    const [householdRows] = await connection.query(`
      SELECT
        h.household_id, h.move_in_date,
        a.apartment_id, a.apartment_number, a.area AS apartment_area, a.status as apartment_status,
        r_head.resident_id AS head_resident_id, r_head.full_name AS head_full_name, 
        r_head.date_of_birth AS head_dob, r_head.cccd_number AS head_cccd
      FROM Households h
      JOIN Apartments a ON h.apartment_id = a.apartment_id
      LEFT JOIN Residents r_head ON h.head_of_household_resident_id = r_head.resident_id
      WHERE h.household_id = ?
    `, [householdId]);

    // Fetch residents and vehicles
    const [residents] = await connection.query('SELECT * FROM Residents WHERE household_id = ?', [householdId]);
    const [vehicles] = await connection.query('SELECT * FROM Vehicles WHERE household_id = ?', [householdId]);

    const household = {
      ...householdRows[0],
      residents,
      vehicles
    };

    res.status(201).json(formatHouseholdResponse(household));
  } catch (error) {
    await connection.rollback();
    if (error.code === 'ER_DUP_ENTRY' && error.message.includes('head_cccd_number')) {
        return res.status(409).json({ message: 'CCCD number for head resident already exists.' });
    }
    if (error.code === 'ER_DUP_ENTRY' && error.message.includes('apartment_id')) {
        return res.status(409).json({ message: 'This apartment is already assigned to a household.' });
    }
    if (error.code === 'ER_NO_REFERENCED_ROW_2' && error.message.includes('apartment_id')) {
        return res.status(404).json({ message: 'Apartment not found.' });
    }
    next(error);
  } finally {
    connection.release();
  }
};

exports.getAllHouseholds = async (req, res, next) => {
  try {
    const query = `
      SELECT
        h.household_id, h.move_in_date,
        a.apartment_id, a.apartment_number, a.area AS apartment_area, a.status as apartment_status,
        r_head.resident_id AS head_resident_id, r_head.full_name AS head_full_name,
        r_head.date_of_birth AS head_dob, r_head.cccd_number AS head_cccd
      FROM Households h
      JOIN Apartments a ON h.apartment_id = a.apartment_id
      LEFT JOIN Residents r_head ON h.head_of_household_resident_id = r_head.resident_id
      ORDER BY a.apartment_number
    `;
    const [households] = await pool.query(query);
    
    // For each household, fetch its residents and vehicles
    const householdsWithDetails = await Promise.all(households.map(async (household) => {
      const [residents] = await pool.query('SELECT * FROM Residents WHERE household_id = ?', [household.household_id]);
      const [vehicles] = await pool.query('SELECT * FROM Vehicles WHERE household_id = ?', [household.household_id]);
      return { ...household, residents, vehicles };
    }));

    res.json(householdsWithDetails.map(formatHouseholdResponse));
  } catch (error) {
    next(error);
  }
};

exports.getHouseholdDetailsById = async (req, res, next) => {
    const { id } = req.params;
    try {
        const [householdRows] = await pool.query(`
            SELECT
                h.household_id, h.move_in_date,
                a.apartment_id, a.apartment_number, a.area AS apartment_area, a.status as apartment_status,
                r_head.resident_id AS head_resident_id, r_head.full_name AS head_full_name,
                r_head.date_of_birth AS head_dob, r_head.cccd_number AS head_cccd
            FROM Households h
            JOIN Apartments a ON h.apartment_id = a.apartment_id
            LEFT JOIN Residents r_head ON h.head_of_household_resident_id = r_head.resident_id
            WHERE h.household_id = ?
        `, [id]);

        if (householdRows.length === 0) {
            return res.status(404).json({ message: 'Household not found.' });
        }

        const [residents] = await pool.query('SELECT * FROM Residents WHERE household_id = ?', [id]);
        const [vehicles] = await pool.query('SELECT * FROM Vehicles WHERE household_id = ?', [id]);

        const household = {
            ...householdRows[0],
            residents,
            vehicles
        };

        res.json(formatHouseholdResponse(household));
    } catch (error) {
        next(error);
    }
};

// --- Resident Management (UC-05 Manage Household Members) ---
exports.addResidentToHousehold = async (req, res, next) => {
  const { household_id } = req.params;
  const { full_name, date_of_birth, cccd_number, role_in_household } = req.body;

  if (!full_name || !role_in_household) {
    return res.status(400).json({ message: 'Full name and role are required.' });
  }
  try {
    // Check if household exists
    const [householdExists] = await pool.query('SELECT household_id FROM Households WHERE household_id = ?', [household_id]);
    if (householdExists.length === 0) {
        return res.status(404).json({ message: 'Household not found.' });
    }

    const [result] = await pool.query(
      'INSERT INTO Residents (household_id, full_name, date_of_birth, cccd_number, role_in_household) VALUES (?, ?, ?, ?, ?)',
      [household_id, full_name, date_of_birth, cccd_number, role_in_household]
    );
    res.status(201).json({ message: 'Resident added successfully', residentId: result.insertId });
  } catch (error) {
     if (error.code === 'ER_DUP_ENTRY' && error.message.includes('cccd_number')) {
        return res.status(409).json({ message: 'CCCD number already exists for another resident.' });
    }
    next(error);
  }
};

exports.updateResident = async (req, res, next) => {
    const { resident_id } = req.params;
    // household_id is not typically updated this way, rather a resident might move.
    // Here we update personal details.
    const { full_name, date_of_birth, cccd_number, role_in_household } = req.body;
    if (!full_name || !role_in_household) {
        return res.status(400).json({ message: 'Full name and role are required.' });
    }
    try {
        const [result] = await pool.query(
            'UPDATE Residents SET full_name = ?, date_of_birth = ?, cccd_number = ?, role_in_household = ? WHERE resident_id = ?',
            [full_name, date_of_birth, cccd_number, role_in_household, resident_id]
        );
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Resident not found or no changes made.'});
        }
        res.json({ message: 'Resident updated successfully.'});
    } catch (error) {
        if (error.code === 'ER_DUP_ENTRY' && error.message.includes('cccd_number')) {
            return res.status(409).json({ message: 'CCCD number already exists for another resident.' });
        }
        next(error);
    }
};

exports.deleteResident = async (req, res, next) => {
    const { resident_id } = req.params;
    try {
        // Check if this resident is a head_of_household
        const [isHead] = await pool.query('SELECT household_id FROM Households WHERE head_of_household_resident_id = ?', [resident_id]);
        if (isHead.length > 0) {
            return res.status(400).json({ message: `Cannot delete resident. They are a head of household for household ID ${isHead[0].household_id}. Please assign a new head first or delete the household.` });
        }

        const [result] = await pool.query('DELETE FROM Residents WHERE resident_id = ?', [resident_id]);
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Resident not found.' });
        }
        res.json({ message: 'Resident deleted successfully.' });
    } catch (error) {
        next(error);
    }
};

// --- Vehicle Management (UC-04 from SRS pg 20 - Register Vehicle for household) ---
exports.addVehicleToHousehold = async (req, res, next) => {
  const { household_id } = req.params; // Or req.body if preferred
  const { plate_number, vehicle_type, registration_date } = req.body;

  if (!household_id || !plate_number || !vehicle_type) {
    return res.status(400).json({ message: 'Household ID, plate number, and vehicle type are required.' });
  }
  try {
    // Check if household exists
    const [householdExists] = await pool.query('SELECT household_id FROM Households WHERE household_id = ?', [household_id]);
    if (householdExists.length === 0) {
        return res.status(404).json({ message: 'Household not found.' });
    }

    const [result] = await pool.query(
      'INSERT INTO Vehicles (household_id, plate_number, vehicle_type, registration_date) VALUES (?, ?, ?, ?)',
      [household_id, plate_number, vehicle_type, registration_date]
    );
    res.status(201).json({ message: 'Vehicle registered successfully', vehicleId: result.insertId });
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') {
        return res.status(409).json({ message: 'Plate number already registered.' });
    }
    next(error);
  }
};

exports.getVehiclesByHousehold = async (req, res, next) => {
    const { household_id } = req.params;
    try {
        const [vehicles] = await pool.query('SELECT * FROM Vehicles WHERE household_id = ?', [household_id]);
        res.json(vehicles);
    } catch (error) {
        next(error);
    }
};

exports.updateVehicle = async (req, res, next) => {
    const { vehicle_id } = req.params;
    const { plate_number, vehicle_type, registration_date } = req.body;
     if (!plate_number || !vehicle_type) {
        return res.status(400).json({ message: 'Plate number and vehicle type are required.' });
    }
    try {
        const [result] = await pool.query(
            'UPDATE Vehicles SET plate_number = ?, vehicle_type = ?, registration_date = ? WHERE vehicle_id = ?',
            [plate_number, vehicle_type, registration_date, vehicle_id]
        );
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Vehicle not found or no changes made.' });
        }
        res.json({ message: 'Vehicle updated successfully.'});
    } catch (error) {
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({ message: 'Plate number already registered for another vehicle.' });
        }
        next(error);
    }
};

exports.deleteVehicle = async (req, res, next) => {
    const { vehicle_id } = req.params;
    try {
        const [result] = await pool.query('DELETE FROM Vehicles WHERE vehicle_id = ?', [vehicle_id]);
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Vehicle not found.' });
        }
        res.json({ message: 'Vehicle deleted successfully.' });
    } catch (error) {
        next(error);
    }
};

exports.getResidentsCount = async (req, res, next) => {
  try {
    const [rows] = await pool.query('SELECT COUNT(*) AS count FROM Residents');
    res.json({ count: rows[0].count });
  } catch (error) {
    next(error);
  }
};