package com.bluemoon.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;

public class VehicleDto {
    
    @JsonProperty("vehicle_id")
    private String vehicleId;
    
    @JsonProperty("household_id")
    private String householdId;
    
    @JsonProperty("plate_number")
    @NotBlank(message = "Plate number is required")
    private String plateNumber;
    
    @JsonProperty("vehicle_type")
    @NotBlank(message = "Vehicle type is required")
    private String vehicleType;
    
    @JsonProperty("registration_date")
    private String registrationDate;
    
    // Constructors
    public VehicleDto() {}
    
    public VehicleDto(String vehicleId, String householdId, String plateNumber, 
                     String vehicleType, String registrationDate) {
        this.vehicleId = vehicleId;
        this.householdId = householdId;
        this.plateNumber = plateNumber;
        this.vehicleType = vehicleType;
        this.registrationDate = registrationDate;
    }
    
    // Getters and Setters
    public String getVehicleId() {
        return vehicleId;
    }
    
    public void setVehicleId(String vehicleId) {
        this.vehicleId = vehicleId;
    }
    
    public String getHouseholdId() {
        return householdId;
    }
    
    public void setHouseholdId(String householdId) {
        this.householdId = householdId;
    }
    
    public String getPlateNumber() {
        return plateNumber;
    }
    
    public void setPlateNumber(String plateNumber) {
        this.plateNumber = plateNumber;
    }
    
    public String getVehicleType() {
        return vehicleType;
    }
    
    public void setVehicleType(String vehicleType) {
        this.vehicleType = vehicleType;
    }
    
    public String getRegistrationDate() {
        return registrationDate;
    }
    
    public void setRegistrationDate(String registrationDate) {
        this.registrationDate = registrationDate;
    }
} 