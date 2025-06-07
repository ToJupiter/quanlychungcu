package com.bluemoon.controller;

import com.bluemoon.model.Staff;
import com.bluemoon.repository.*;
import com.bluemoon.repository.StaffRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.sql.DataSource;
import java.sql.Connection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/test")
public class TestController {
    
    @Autowired
    private DataSource dataSource;
    
    @Autowired
    private StaffRepository staffRepository;
    
    @Autowired
    private ApartmentRepository apartmentRepository;
    
    @Autowired
    private HouseholdRepository householdRepository;
    
    @Autowired
    private ResidentRepository residentRepository;
    
    @Autowired
    private VehicleRepository vehicleRepository;
    
    @Autowired
    private PaymentRepository paymentRepository;
    
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> healthCheck() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("message", "BlueMoon Spring Boot Backend is running");
        response.put("timestamp", System.currentTimeMillis());
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/database")
    public ResponseEntity<Map<String, Object>> testDatabase() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Test database connection
            Connection connection = dataSource.getConnection();
            String databaseName = connection.getCatalog();
            String url = connection.getMetaData().getURL();
            connection.close();
            
            response.put("status", "SUCCESS");
            response.put("message", "Database connection successful");
            response.put("database", databaseName);
            response.put("url", url);
            
        } catch (Exception e) {
            response.put("status", "ERROR");
            response.put("message", "Database connection failed: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
        
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/staff-count")
    public ResponseEntity<Map<String, Object>> getStaffCount() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            long count = staffRepository.count();
            List<Staff> staff = staffRepository.findAll();
            
            response.put("status", "SUCCESS");
            response.put("message", "Staff data retrieved successfully");
            response.put("count", count);
            response.put("staff_list", staff);
            
        } catch (Exception e) {
            response.put("status", "ERROR");
            response.put("message", "Failed to retrieve staff data: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
        
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/tables")
    public ResponseEntity<Map<String, Object>> testTables() {
        Map<String, Object> response = new HashMap<>();
        Map<String, Long> tableCounts = new HashMap<>();
        
        try {
            // Test all entity tables
            tableCounts.put("staff", staffRepository.count());
            tableCounts.put("apartments", apartmentRepository.count());
            tableCounts.put("households", householdRepository.count());
            tableCounts.put("residents", residentRepository.count());
            tableCounts.put("vehicles", vehicleRepository.count());
            tableCounts.put("payments", paymentRepository.count());
            
            response.put("status", "SUCCESS");
            response.put("message", "All tables accessible");
            response.put("table_counts", tableCounts);
            
        } catch (Exception e) {
            response.put("status", "ERROR");
            response.put("message", "Failed to access tables: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
        
        return ResponseEntity.ok(response);
    }
} 