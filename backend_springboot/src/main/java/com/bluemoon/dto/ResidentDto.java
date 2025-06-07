package com.bluemoon.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class ResidentDto {
    
    @JsonProperty("resident_id")
    private String residentId;
    
    @JsonProperty("household_id")
    @NotNull(message = "Household ID is required")
    private String householdId;
    
    @JsonProperty("full_name")
    @NotBlank(message = "Full name is required")
    @Size(max = 255, message = "Full name must not exceed 255 characters")
    private String fullName;
    
    @JsonProperty("date_of_birth")
    private String dateOfBirth; // ISO date string format
    
    @JsonProperty("cccd_number")
    @Size(max = 20, message = "CCCD number must not exceed 20 characters")
    private String cccdNumber;
    
    @JsonProperty("role_in_household")
    @Size(max = 50, message = "Role in household must not exceed 50 characters")
    private String roleInHousehold;
    
    // Default constructor
    public ResidentDto() {}
    
    // Constructor
    public ResidentDto(String residentId, String householdId, String fullName, String dateOfBirth, String cccdNumber, String roleInHousehold) {
        this.residentId = residentId;
        this.householdId = householdId;
        this.fullName = fullName;
        this.dateOfBirth = dateOfBirth;
        this.cccdNumber = cccdNumber;
        this.roleInHousehold = roleInHousehold;
    }
    
    // Getters and Setters
    public String getResidentId() {
        return residentId;
    }
    
    public void setResidentId(String residentId) {
        this.residentId = residentId;
    }
    
    public String getHouseholdId() {
        return householdId;
    }
    
    public void setHouseholdId(String householdId) {
        this.householdId = householdId;
    }
    
    public String getFullName() {
        return fullName;
    }
    
    public void setFullName(String fullName) {
        this.fullName = fullName;
    }
    
    public String getDateOfBirth() {
        return dateOfBirth;
    }
    
    public void setDateOfBirth(String dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }
    
    public String getCccdNumber() {
        return cccdNumber;
    }
    
    public void setCccdNumber(String cccdNumber) {
        this.cccdNumber = cccdNumber;
    }
    
    public String getRoleInHousehold() {
        return roleInHousehold;
    }
    
    public void setRoleInHousehold(String roleInHousehold) {
        this.roleInHousehold = roleInHousehold;
    }
} 