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

import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

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
     * Returns: { "message": "Staff registered successfully", "staffId": string }
     */
    public Map<String, Object> registerStaff(AuthRequest request) {
        // Check if email already exists
        if (staffRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists");
        }
        
        // Create new staff
        Staff staff = new Staff();
        staff.setStaffId(UUID.randomUUID().toString());
        staff.setFullName(request.getFullName());
        staff.setEmail(request.getEmail());
        staff.setPhoneNumber(request.getPhoneNumber());
        staff.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        staff.setStatus(request.getStatus() != null ? request.getStatus() : "active");
        // Default role is Accountant (1) unless specified otherwise
        staff.setRoles(1);
        
        Staff savedStaff = staffRepository.save(staff);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Staff registered successfully");
        response.put("staffId", savedStaff.getStaffId());
        
        return response;
    }
    
    /**
     * Staff login - matches POST /api/auth/staff/login
     * Returns: { "message": "Login successful", "token": "JWT", "user": {...} } - matching React frontend expectations
     */
    public Map<String, Object> loginStaff(AuthRequest request) {
        // Find staff by email
        Staff staff = staffRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Invalid credentials"));
        
        // Check if staff is active
        if (!"active".equals(staff.getStatus())) {
            throw new RuntimeException("Account is not active");
        }
        
        // Check password
        if (!passwordEncoder.matches(request.getPassword(), staff.getPasswordHash())) {
            throw new RuntimeException("Invalid credentials");
        }
        
        // Generate JWT token with role information
        String token = jwtUtil.generateTokenWithRole(staff.getEmail(), staff.getRoleDisplay());
        
        // Create user object that matches React frontend expectations
        Map<String, Object> userData = new HashMap<>();
        userData.put("staff_id", staff.getStaffId());
        userData.put("full_name", staff.getFullName());
        userData.put("email", staff.getEmail());
        userData.put("phone_number", staff.getPhoneNumber());
        userData.put("status", staff.getStatus());
        userData.put("roles", staff.getRoles());
        userData.put("role_display", staff.getRoleDisplay());
        userData.put("is_admin", staff.isAdmin());
        userData.put("is_accountant", staff.isAccountant());
        
        // Format created_at to ISO string if it exists
        if (staff.getCreatedAt() != null) {
            userData.put("created_at", staff.getCreatedAt().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        }
        
        // Return response matching React frontend LoginResponse interface
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Login successful");
        response.put("token", token);
        response.put("user", userData);
        
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
    
    /**
     * Get staff role from token
     */
    public String getStaffRoleFromToken(String token) {
        if (!jwtUtil.validateToken(token)) {
            throw new CustomException.AuthenticationException("Invalid or expired token");
        }
        
        return jwtUtil.getRoleFromToken(token);
    }
    
    /**
     * Check if staff has admin role
     */
    public boolean isAdmin(String email) {
        Staff staff = staffRepository.findByEmail(email)
                .orElseThrow(() -> new CustomException.AuthenticationException("Staff not found"));
        return staff.isAdmin();
    }
    
    /**
     * Check if staff has accountant role
     */
    public boolean isAccountant(String email) {
        Staff staff = staffRepository.findByEmail(email)
                .orElseThrow(() -> new CustomException.AuthenticationException("Staff not found"));
        return staff.isAccountant();
    }
} 