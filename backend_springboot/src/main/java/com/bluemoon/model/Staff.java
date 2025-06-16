package com.bluemoon.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "Staff")
public class Staff {
    
    @Id
    @Column(name = "staff_id", length = 50)
    private String staffId;
    
    @Column(name = "full_name", nullable = false, length = 255)
    private String fullName;
    
    @Column(name = "email", nullable = false, unique = true, length = 255)
    private String email;
    
    @Column(name = "phone_number", length = 20)
    private String phoneNumber;
    
    @Column(name = "password_hash", nullable = false, length = 255)
    private String passwordHash;
    
    @Column(name = "status", length = 50)
    private String status;
    
    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "Roles", nullable = false)
    private Integer roles; // 0 = Admin, 1 = Accountant

    // Default constructor
    public Staff() {}

    // Constructor
    public Staff(String staffId, String fullName, String email, String phoneNumber, String passwordHash, String status, Integer roles) {
        this.staffId = staffId;
        this.fullName = fullName;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.passwordHash = passwordHash;
        this.status = status;
        this.roles = roles;
        this.createdAt = LocalDateTime.now();
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

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public Integer getRoles() {
        return roles;
    }

    public void setRoles(Integer roles) {
        this.roles = roles;
    }

    // Helper methods for role checking
    public boolean isAdmin() {
        return roles != null && roles == 0;
    }

    public boolean isAccountant() {
        return roles != null && roles == 1;
    }

    public String getRoleDisplay() {
        if (roles == null) return "Unknown";
        return roles == 0 ? "Admin" : "Accountant";
    }

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        if (status == null) {
            status = "active";
        }
        if (roles == null) {
            roles = 1; // Default to Accountant
        }
    }
} 