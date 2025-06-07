package com.bluemoon.service;

import com.bluemoon.dto.StaffDto;
import com.bluemoon.model.Staff;
import com.bluemoon.repository.StaffRepository;
import com.bluemoon.util.MapperUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class StaffService {
    
    @Autowired
    private StaffRepository staffRepository;
    
    @Autowired
    private MapperUtil mapperUtil;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    /**
     * Get all staff with optional filtering - matches Node.js getAllStaff
     */
    public List<StaffDto> getAllStaff(String status, String search) {
        List<Staff> staffList;
        
        if (status != null || search != null) {
            staffList = staffRepository.findStaffWithFilters(status, search);
        } else {
            staffList = staffRepository.findAllByOrderByCreatedAtDesc();
        }
        
        return staffList.stream()
                .map(mapperUtil::toStaffDto)
                .collect(Collectors.toList());
    }
    
    /**
     * Get staff by ID - matches Node.js getStaffById
     */
    public StaffDto getStaffById(String id) {
        Integer staffId = Integer.parseInt(id);
        Staff staff = staffRepository.findById(staffId)
                .orElseThrow(() -> new RuntimeException("Staff not found"));
        return mapperUtil.toStaffDto(staff);
    }
    
    /**
     * Create new staff - matches Node.js createStaff
     */
    public Map<String, Object> createStaff(StaffDto staffDto) {
        // Check if email already exists
        if (staffRepository.existsByEmail(staffDto.getEmail())) {
            throw new RuntimeException("Email already exists");
        }
        
        // Convert DTO to entity
        Staff staff = mapperUtil.toStaffEntity(staffDto);
        
        // Encode password if provided
        if (staffDto.getPassword() != null) {
            staff.setPasswordHash(passwordEncoder.encode(staffDto.getPassword()));
        }
        
        // Set default status if not provided
        if (staff.getStatus() == null) {
            staff.setStatus("active");
        }
        
        Staff savedStaff = staffRepository.save(staff);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Staff created successfully");
        response.put("staffId", savedStaff.getStaffId().toString());
        
        return response;
    }
    
    /**
     * Update staff - matches Node.js updateStaff
     */
    public Map<String, Object> updateStaff(String id, StaffDto staffDto) {
        Integer staffId = Integer.parseInt(id);
        Staff existingStaff = staffRepository.findById(staffId)
                .orElseThrow(() -> new RuntimeException("Staff not found"));
        
        // Check if email is being changed and if it already exists
        if (!existingStaff.getEmail().equals(staffDto.getEmail()) && 
            staffRepository.existsByEmailAndStaffIdNot(staffDto.getEmail(), staffId)) {
            throw new RuntimeException("Email already exists");
        }
        
        // Update fields
        existingStaff.setFullName(staffDto.getFullName());
        existingStaff.setEmail(staffDto.getEmail());
        existingStaff.setPhoneNumber(staffDto.getPhoneNumber());
        existingStaff.setStatus(staffDto.getStatus());
        
        staffRepository.save(existingStaff);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Staff updated successfully");
        
        return response;
    }
    
    /**
     * Update staff status - matches Node.js updateStaffStatus
     */
    public Map<String, Object> updateStaffStatus(String id, String status) {
        Integer staffId = Integer.parseInt(id);
        Staff staff = staffRepository.findById(staffId)
                .orElseThrow(() -> new RuntimeException("Staff not found"));
        
        if (status == null || (!status.equals("active") && !status.equals("inactive"))) {
            throw new RuntimeException("Valid status (active or inactive) is required");
        }
        
        staff.setStatus(status);
        staffRepository.save(staff);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Staff status updated successfully");
        
        return response;
    }
    
    /**
     * Reset staff password - matches Node.js resetStaffPassword
     */
    public Map<String, Object> resetStaffPassword(String id, String password) {
        Integer staffId = Integer.parseInt(id);
        Staff staff = staffRepository.findById(staffId)
                .orElseThrow(() -> new RuntimeException("Staff not found"));
        
        if (password == null || password.length() < 6) {
            throw new RuntimeException("Password must be at least 6 characters long");
        }
        
        staff.setPasswordHash(passwordEncoder.encode(password));
        staffRepository.save(staff);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Password reset successfully");
        
        return response;
    }
    
    /**
     * Delete (deactivate) staff - matches Node.js deleteStaff
     */
    public Map<String, Object> deleteStaff(String id) {
        Integer staffId = Integer.parseInt(id);
        Staff staff = staffRepository.findById(staffId)
                .orElseThrow(() -> new RuntimeException("Staff not found"));
        
        // Soft delete by setting status to inactive
        staff.setStatus("inactive");
        staffRepository.save(staff);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Staff deleted successfully");
        
        return response;
    }
    
    /**
     * Get staff statistics - matches Node.js getStaffStats
     */
    public Map<String, Object> getStaffStats() {
        Long totalStaff = staffRepository.count();
        Long activeStaff = staffRepository.countByStatus("active");
        Long inactiveStaff = staffRepository.countByStatus("inactive");
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("total", totalStaff);
        stats.put("active", activeStaff);
        stats.put("inactive", inactiveStaff);
        
        return stats;
    }
} 