package com.bluemoon.controller;

import com.bluemoon.dto.StaffDto;
import com.bluemoon.service.StaffService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/staff")
@CrossOrigin(origins = "*")
public class StaffController {
    
    @Autowired
    private StaffService staffService;
    
    // GET /api/staff - Get all staff members (with optional filtering)
    @GetMapping
    public ResponseEntity<?> getAllStaff(@RequestParam(required = false) String status,
                                        @RequestParam(required = false) String search) {
        try {
            List<StaffDto> staff = staffService.getAllStaff(status, search);
            return ResponseEntity.ok(staff);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
    
    // GET /api/staff/stats - Get staff statistics
    @GetMapping("/stats")
    public ResponseEntity<?> getStaffStats() {
        try {
            Map<String, Object> stats = staffService.getStaffStats();
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
    
    // GET /api/staff/:id - Get a single staff member by ID
    @GetMapping("/{id}")
    public ResponseEntity<?> getStaffById(@PathVariable String id) {
        try {
            StaffDto staff = staffService.getStaffById(id);
            return ResponseEntity.ok(staff);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
    
    // POST /api/staff - Create a new staff member
    @PostMapping
    public ResponseEntity<?> createStaff(@Valid @RequestBody StaffDto staffDto) {
        try {
            Map<String, Object> response = staffService.createStaff(staffDto);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
    
    // PUT /api/staff/:id - Update a staff member
    @PutMapping("/{id}")
    public ResponseEntity<?> updateStaff(@PathVariable String id, @Valid @RequestBody StaffDto staffDto) {
        try {
            Map<String, Object> response = staffService.updateStaff(id, staffDto);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
    
    // PATCH /api/staff/:id/status - Update staff status (activate/deactivate)
    @PatchMapping("/{id}/status")
    public ResponseEntity<?> updateStaffStatus(@PathVariable String id, @RequestBody Map<String, String> request) {
        try {
            String status = request.get("status");
            Map<String, Object> response = staffService.updateStaffStatus(id, status);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
    
    // PATCH /api/staff/:id/reset-password - Reset staff password (admin function)
    @PatchMapping("/{id}/reset-password")
    public ResponseEntity<?> resetStaffPassword(@PathVariable String id, @RequestBody Map<String, String> request) {
        try {
            String password = request.get("password");
            Map<String, Object> response = staffService.resetStaffPassword(id, password);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
    
    // DELETE /api/staff/:id - Delete (deactivate) a staff member
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteStaff(@PathVariable String id) {
        try {
            Map<String, Object> response = staffService.deleteStaff(id);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
} 