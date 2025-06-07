package com.bluemoon.controller;

import com.bluemoon.dto.ResidentDto;
import com.bluemoon.service.ResidentService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/management")
@CrossOrigin(origins = "*")
public class ResidentController {
    
    @Autowired
    private ResidentService residentService;
    
    // POST /api/management/households/:household_id/residents - Add resident to household
    @PostMapping("/households/{household_id}/residents")
    public ResponseEntity<?> createResident(@PathVariable("household_id") String householdId, 
                                          @Valid @RequestBody ResidentDto residentDto) {
        try {
            ResidentDto createdResident = residentService.createResident(householdId, residentDto);
            return ResponseEntity.ok(createdResident);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
    
    // GET /api/management/households/:household_id/residents - Get residents by household
    @GetMapping("/households/{household_id}/residents")
    public ResponseEntity<?> getResidentsByHousehold(@PathVariable("household_id") String householdId) {
        try {
            List<ResidentDto> residents = residentService.getResidentsByHousehold(householdId);
            return ResponseEntity.ok(residents);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
    
    // PUT /api/management/residents/:resident_id - Update resident
    @PutMapping("/residents/{resident_id}")
    public ResponseEntity<?> updateResident(@PathVariable("resident_id") String residentId, 
                                          @Valid @RequestBody ResidentDto residentDto) {
        try {
            Map<String, Object> response = residentService.updateResident(residentId, residentDto);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
    
    // DELETE /api/management/residents/:resident_id - Delete resident
    @DeleteMapping("/residents/{resident_id}")
    public ResponseEntity<?> deleteResident(@PathVariable("resident_id") String residentId) {
        try {
            Map<String, Object> response = residentService.deleteResident(residentId);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
    
    // GET /api/management/residents/count - Get total number of residents
    @GetMapping("/residents/count")
    public ResponseEntity<?> getResidentCount() {
        try {
            Map<String, Object> stats = residentService.getResidentStats();
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
} 