package com.bluemoon.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public class ApartmentDto {
    
    @JsonProperty("apartment_id")
    private String apartmentId;
    
    @JsonProperty("apartment_number")
    @NotBlank(message = "Apartment number is required")
    @Size(max = 50, message = "Apartment number must not exceed 50 characters")
    private String apartmentNumber;
    
    @JsonProperty("area")
    @NotNull(message = "Area is required")
    @Positive(message = "Area must be positive")
    private Double area; // Using Double to match Flutter frontend expectations
    
    @JsonProperty("status")
    @Size(max = 50, message = "Status must not exceed 50 characters")
    private String status;
    
    // Default constructor
    public ApartmentDto() {}
    
    // Constructor
    public ApartmentDto(String apartmentId, String apartmentNumber, Double area, String status) {
        this.apartmentId = apartmentId;
        this.apartmentNumber = apartmentNumber;
        this.area = area;
        this.status = status;
    }
    
    // Getters and Setters
    public String getApartmentId() {
        return apartmentId;
    }
    
    public void setApartmentId(String apartmentId) {
        this.apartmentId = apartmentId;
    }
    
    public String getApartmentNumber() {
        return apartmentNumber;
    }
    
    public void setApartmentNumber(String apartmentNumber) {
        this.apartmentNumber = apartmentNumber;
    }
    
    public Double getArea() {
        return area;
    }
    
    public void setArea(Double area) {
        this.area = area;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
} 