package com.bluemoon.controller;

import com.bluemoon.dto.AuthRequest;
import com.bluemoon.dto.StaffDto;
import com.bluemoon.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {
    
    @Autowired
    private AuthService authService;
    
    /**
     * Staff registration endpoint
     * POST /api/auth/staff/register
     * Returns: { "message": "Staff registered successfully", "staffId": number }
     */
    @PostMapping("/staff/register")
    public ResponseEntity<?> registerStaff(@Valid @RequestBody AuthRequest request) {
        try {
            Map<String, Object> response = authService.registerStaff(request);
            return ResponseEntity.status(201).body(response);
        } catch (RuntimeException e) {
            String message = e.getMessage();
            if (message.contains("Email already exists")) {
                return ResponseEntity.status(409).body(Map.of("message", "Email already in use"));
            } else {
                return ResponseEntity.status(400).body(Map.of("message", message));
            }
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("message", "Internal server error"));
        }
    }
    
    /**
     * Staff login endpoint
     * POST /api/auth/staff/login
     * Returns: { "message": "Login successful", "token": "JWT", "user": {...} }
     */
    @PostMapping("/staff/login")
    public ResponseEntity<?> loginStaff(@Valid @RequestBody AuthRequest request) {
        try {
            Map<String, Object> response = authService.loginStaff(request);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            String message = e.getMessage();
            if (message.contains("Invalid credentials") || message.contains("email not found") || message.contains("password incorrect")) {
                return ResponseEntity.status(401).body(Map.of("message", message));
            } else if (message.contains("Account is not active")) {
                return ResponseEntity.status(403).body(Map.of("message", message));
            } else {
                return ResponseEntity.status(400).body(Map.of("message", message));
            }
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("message", "Internal server error"));
        }
    }
    
    /**
     * Change password endpoint
     * POST /api/auth/staff/change-password
     * Returns: { "message": "Password changed successfully" }
     */
    @PostMapping("/staff/change-password")
    public ResponseEntity<?> changePassword(@Valid @RequestBody AuthRequest request, Authentication authentication) {
        try {
            String staffEmail = authentication.getName();
            Map<String, Object> response = authService.changePassword(staffEmail, request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
} 