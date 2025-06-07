package com.bluemoon.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class AuthRequest {
    
    // Login request fields
    @JsonProperty("email")
    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    private String email;
    
    @JsonProperty("password")
    @NotBlank(message = "Password is required")
    private String password;
    
    // Registration additional fields
    @JsonProperty("full_name")
    @Size(max = 255, message = "Full name must not exceed 255 characters")
    private String fullName;
    
    @JsonProperty("phone_number")
    @Size(max = 20, message = "Phone number must not exceed 20 characters")
    private String phoneNumber;
    
    @JsonProperty("status")
    @Size(max = 50, message = "Status must not exceed 50 characters")
    private String status;
    
    // Password change fields
    @JsonProperty("oldPassword")
    private String oldPassword;
    
    @JsonProperty("newPassword")
    private String newPassword;
    
    // Default constructor
    public AuthRequest() {}
    
    // Constructor for login
    public AuthRequest(String email, String password) {
        this.email = email;
        this.password = password;
    }
    
    // Constructor for registration
    public AuthRequest(String email, String password, String fullName, String phoneNumber, String status) {
        this.email = email;
        this.password = password;
        this.fullName = fullName;
        this.phoneNumber = phoneNumber;
        this.status = status;
    }
    
    // Getters and Setters
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password) {
        this.password = password;
    }
    
    public String getFullName() {
        return fullName;
    }
    
    public void setFullName(String fullName) {
        this.fullName = fullName;
    }
    
    public String getPhoneNumber() {
        return phoneNumber;
    }
    
    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getOldPassword() {
        return oldPassword;
    }
    
    public void setOldPassword(String oldPassword) {
        this.oldPassword = oldPassword;
    }
    
    public String getNewPassword() {
        return newPassword;
    }
    
    public void setNewPassword(String newPassword) {
        this.newPassword = newPassword;
    }
} 