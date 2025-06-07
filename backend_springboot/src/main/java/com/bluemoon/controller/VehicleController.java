package com.bluemoon.controller;

import com.bluemoon.dto.VehicleDto;
import com.bluemoon.service.VehicleService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/management")
@CrossOrigin(origins = "*")
public class VehicleController {
    
    @Autowired
    private VehicleService vehicleService;
    
    // POST /api/management/households/:household_id/vehicles - Add/register vehicle to household
    @PostMapping("/households/{household_id}/vehicles")
    public ResponseEntity<?> createVehicle(@PathVariable("household_id") String householdId, 
                                         @Valid @RequestBody VehicleDto vehicleDto) {
        try {
            VehicleDto createdVehicle = vehicleService.createVehicle(householdId, vehicleDto);
            return ResponseEntity.ok(createdVehicle);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
    
    // GET /api/management/households/:household_id/vehicles - Get vehicles for household
    @GetMapping("/households/{household_id}/vehicles")
    public ResponseEntity<?> getVehiclesByHousehold(@PathVariable("household_id") String householdId) {
        try {
            List<VehicleDto> vehicles = vehicleService.getVehiclesByHousehold(householdId);
            return ResponseEntity.ok(vehicles);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
    
    // GET /api/management/vehicles - Get all vehicles with optional filtering
    @GetMapping("/vehicles")
    public ResponseEntity<?> getAllVehicles(@RequestParam(required = false) String plateNumber,
                                          @RequestParam(required = false) String vehicleType) {
        try {
            List<VehicleDto> vehicles = vehicleService.getAllVehicles(plateNumber, vehicleType);
            return ResponseEntity.ok(vehicles);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
    
    // PUT /api/management/vehicles/:vehicle_id - Update vehicle
    @PutMapping("/vehicles/{vehicle_id}")
    public ResponseEntity<?> updateVehicle(@PathVariable("vehicle_id") String vehicleId, 
                                         @Valid @RequestBody VehicleDto vehicleDto) {
        try {
            Map<String, Object> response = vehicleService.updateVehicle(vehicleId, vehicleDto);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
    
    // DELETE /api/management/vehicles/:vehicle_id - Delete vehicle
    @DeleteMapping("/vehicles/{vehicle_id}")
    public ResponseEntity<?> deleteVehicle(@PathVariable("vehicle_id") String vehicleId) {
        try {
            Map<String, Object> response = vehicleService.deleteVehicle(vehicleId);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
    
    // GET /api/management/vehicles/stats - Get vehicle statistics
    @GetMapping("/vehicles/stats")
    public ResponseEntity<?> getVehicleStats() {
        try {
            Map<String, Object> stats = vehicleService.getVehicleStats();
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
} 