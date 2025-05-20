// routes/management.routes.js
const express = require('express');
const router = express.Router();
const managementController = require('../controllers/management.controller');
const { authenticateToken } = require('../middlewares'); // Protect all management routes

// Apply authentication middleware to all routes in this file
router.use(authenticateToken);

// --- Apartment Routes ---
// POST /api/management/apartments - Create a new apartment
router.post('/apartments', managementController.createApartment);
// GET /api/management/apartments - Get all apartments
router.get('/apartments', managementController.getAllApartments);
// GET /api/management/apartments/:id - Get a single apartment by ID
router.get('/apartments/:id', managementController.getApartmentById);
// PUT /api/management/apartments/:id - Update an apartment by ID
router.put('/apartments/:id', managementController.updateApartment);
// DELETE /api/management/apartments/:id - Delete an apartment by ID
router.delete('/apartments/:id', managementController.deleteApartment);


// --- Household Routes ---
// UC-04: Create a new household (typically includes creating the head resident)
router.post('/households', managementController.createHouseholdWithHead);
// UC-06: Get all households (summary)
router.get('/households', managementController.getAllHouseholds);
// UC-06 extended: Get detailed information for a single household (including residents, vehicles)
router.get('/households/:id/details', managementController.getHouseholdDetailsById);
// (PUT and DELETE for households might be complex, involving resident and vehicle management)


// --- Resident Routes (related to a household) ---
// UC-05: Add a new resident to an existing household
router.post('/households/:household_id/residents', managementController.addResidentToHousehold);
// UC-05: Update an existing resident's details
router.put('/residents/:resident_id', managementController.updateResident);
// UC-05: Remove a resident from a household (or delete resident record)
router.delete('/residents/:resident_id', managementController.deleteResident);

// GET /api/management/residents/count - Get total number of residents
router.get('/residents/count', managementController.getResidentsCount);


// --- Vehicle Routes (related to a household) ---
// UC-04 (SRS pg 20): Add/Register a new vehicle to a household
router.post('/households/:household_id/vehicles', managementController.addVehicleToHousehold);
// GET vehicles for a specific household
router.get('/households/:household_id/vehicles', managementController.getVehiclesByHousehold);
// Update vehicle details
router.put('/vehicles/:vehicle_id', managementController.updateVehicle);
// Delete a vehicle
router.delete('/vehicles/:vehicle_id', managementController.deleteVehicle);

// (UC-04 "Send notification" could be a separate service or feature. If simple, can be added here or to a notification controller)

module.exports = router;