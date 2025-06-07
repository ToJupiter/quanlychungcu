package com.bluemoon.service;

import com.bluemoon.config.JwtUtil;
import com.bluemoon.dto.AuthRequest;
import com.bluemoon.dto.StaffDto;
import com.bluemoon.exception.CustomException;
import com.bluemoon.model.Staff;
import com.bluemoon.repository.StaffRepository;
import com.bluemoon.util.MapperUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class AuthService {
    
    @Autowired
    private StaffRepository staffRepository;
    
    @Autowired
    private MapperUtil mapperUtil;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Autowired
    private JwtUtil jwtUtil;
    
    /**
     * Staff registration - matches POST /api/auth/staff/register
     * Returns: { "message": "Staff registered successfully", "staffId": number }
     */
    public Map<String, Object> registerStaff(AuthRequest request) {
        // Check if email already exists
        if (staffRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists");
        }
        
        // Create new staff
        Staff staff = new Staff();
        staff.setFullName(request.getFullName());
        staff.setEmail(request.getEmail());
        staff.setPhoneNumber(request.getPhoneNumber());
        staff.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        staff.setStatus(request.getStatus() != null ? request.getStatus() : "active");
        
        Staff savedStaff = staffRepository.save(staff);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Staff registered successfully");
        response.put("staffId", savedStaff.getStaffId().toString());
        
        return response;
    }
    
    /**
     * Staff login - matches POST /api/auth/staff/login
     * Returns: { "message": "Login successful", "token": "JWT", "user": {...} }
     */
    public Map<String, Object> loginStaff(AuthRequest request) {
        // Find staff by email
        Staff staff = staffRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Invalid credentials (email not found)"));
        
        // Check if staff is active
        if (!"active".equals(staff.getStatus())) {
            throw new RuntimeException("Account is not active.");
        }
        
        // Check password
        if (!passwordEncoder.matches(request.getPassword(), staff.getPasswordHash())) {
            throw new RuntimeException("Invalid credentials (password incorrect)");
        }
        
        // Create user payload that matches Node.js exactly
        Map<String, Object> userPayload = new HashMap<>();
        userPayload.put("staff_id", staff.getStaffId().toString());
        userPayload.put("email", staff.getEmail());
        userPayload.put("name", staff.getFullName());
        
        // Generate JWT token with the payload
        String token = jwtUtil.generateToken(staff.getEmail());
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Login successful");
        response.put("token", token);
        response.put("user", userPayload);  // Changed from "staff" to "user" to match Node.js
        
        return response;
    }
    
    /**
     * Change password - matches POST /api/auth/staff/change-password
     * Returns: { "message": "Password changed successfully" }
     */
    public Map<String, Object> changePassword(String email, AuthRequest request) {
        // Find staff by email
        Staff staff = staffRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Staff not found"));
        
        // Check old password
        if (!passwordEncoder.matches(request.getOldPassword(), staff.getPasswordHash())) {
            throw new RuntimeException("Current password is incorrect");
        }
        
        // Validate new password
        if (request.getNewPassword() == null || request.getNewPassword().length() < 6) {
            throw new RuntimeException("New password must be at least 6 characters long");
        }
        
        // Update password
        staff.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        staffRepository.save(staff);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Password changed successfully");
        
        return response;
    }
    
    /**
     * Validate JWT token and get staff info
     */
    public Staff validateTokenAndGetStaff(String token) {
        if (!jwtUtil.validateToken(token)) {
            throw new CustomException.AuthenticationException("Invalid or expired token");
        }
        
        String email = jwtUtil.getEmailFromToken(token);
        return staffRepository.findByEmail(email)
                .orElseThrow(() -> new CustomException.AuthenticationException("Staff not found"));
    }
} 