package com.bluemoon.controller;

import com.bluemoon.dto.HouseholdDto;
import com.bluemoon.service.HouseholdService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/management/households")
@CrossOrigin(origins = "*")
public class HouseholdController {
    
    @Autowired
    private HouseholdService householdService;
    
    // POST /api/management/households - Create household
    @PostMapping
    public ResponseEntity<?> createHousehold(@Valid @RequestBody HouseholdDto householdDto) {
        try {
            HouseholdDto createdHousehold = householdService.createHousehold(householdDto);
            return ResponseEntity.ok(createdHousehold);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
    
    // GET /api/management/households - Get all households
    @GetMapping
    public ResponseEntity<?> getAllHouseholds(@RequestParam(required = false) String apartmentNumber) {
        try {
            List<HouseholdDto> households = householdService.getAllHouseholds(apartmentNumber);
            return ResponseEntity.ok(households);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
    
    // GET /api/management/households/:id - Get household by ID
    @GetMapping("/{id}")
    public ResponseEntity<?> getHouseholdById(@PathVariable String id) {
        try {
            HouseholdDto household = householdService.getHouseholdById(id);
            return ResponseEntity.ok(household);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
    
    // GET /api/management/households/:id/details - Get household details with residents and vehicles
    @GetMapping("/{id}/details")
    public ResponseEntity<?> getHouseholdDetails(@PathVariable String id) {
        try {
            HouseholdDto householdDetails = householdService.getHouseholdDetails(id);
            return ResponseEntity.ok(householdDetails);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
    
    // PUT /api/management/households/:id - Update household
    @PutMapping("/{id}")
    public ResponseEntity<?> updateHousehold(@PathVariable String id, @Valid @RequestBody HouseholdDto householdDto) {
        try {
            Map<String, Object> response = householdService.updateHousehold(id, householdDto);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
    
    // DELETE /api/management/households/:id - Delete household
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteHousehold(@PathVariable String id) {
        try {
            Map<String, Object> response = householdService.deleteHousehold(id);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
    
    // GET /api/management/households/stats - Get household statistics
    @GetMapping("/stats")
    public ResponseEntity<?> getHouseholdStats() {
        try {
            Map<String, Object> stats = householdService.getHouseholdStats();
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
} 