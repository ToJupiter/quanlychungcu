package com.bluemoon.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;

public class StaffDto {
    
    @JsonProperty("staff_id")
    private String staffId;
    
    @JsonProperty("full_name")
    @NotBlank(message = "Full name is required")
    @Size(max = 255, message = "Full name must not exceed 255 characters")
    private String fullName;
    
    @JsonProperty("email")
    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    @Size(max = 255, message = "Email must not exceed 255 characters")
    private String email;
    
    @JsonProperty("phone_number")
    @Size(max = 20, message = "Phone number must not exceed 20 characters")
    private String phoneNumber;
    
    @JsonProperty("status")
    @Size(max = 50, message = "Status must not exceed 50 characters")
    private String status;
    
    @JsonProperty("created_at")
    private String createdAt;
    
    // Password field for creation (not serialized in responses)
    @JsonProperty(value = "password", access = JsonProperty.Access.WRITE_ONLY)
    private String password;

    // Default constructor
    public StaffDto() {}

    // Constructor for response (without password)
    public StaffDto(String staffId, String fullName, String email, String phoneNumber, String status, String createdAt) {
        this.staffId = staffId;
        this.fullName = fullName;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.status = status;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public String getStaffId() {
        return staffId;
    }

    public void setStaffId(String staffId) {
        this.staffId = staffId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }
    
    // Authentication Response DTO
    public static class AuthResponse {
        private String token;
        private StaffDto staff;
        
        public AuthResponse() {}
        
        public AuthResponse(String token, StaffDto staff) {
            this.token = token;
            this.staff = staff;
        }
        
        public String getToken() {
            return token;
        }
        
        public void setToken(String token) {
            this.token = token;
        }
        
        public StaffDto getStaff() {
            return staff;
        }
        
        public void setStaff(StaffDto staff) {
            this.staff = staff;
        }
    }
} 