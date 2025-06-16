package com.bluemoon.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.LocalDate;
import java.util.List;

public class HouseholdDetailDto {
    
    @JsonProperty("household_id")
    private String householdId;
    
    @JsonProperty("apartment_id")
    private String apartmentId;
    
    @JsonProperty("apartment_number")
    private String apartmentNumber;
    
    @JsonProperty("apartment_area")
    private Double apartmentArea;
    
    @JsonProperty("apartment_status")
    private String apartmentStatus;
    
    @JsonProperty("head_resident_id")
    private String headResidentId;
    
    @JsonProperty("head_full_name")
    private String headFullName;
    
    @JsonProperty("head_dob")
    private LocalDate headDob;
    
    @JsonProperty("head_cccd")
    private String headCccd;
    
    @JsonProperty("move_in_date")
    private LocalDate moveInDate;
    
    @JsonProperty("residents")
    private List<ResidentDto> residents;
    
    @JsonProperty("vehicles")
    private List<VehicleDto> vehicles;
    
    // Constructors
    public HouseholdDetailDto() {}
    
    public HouseholdDetailDto(String householdId, String apartmentId, String apartmentNumber, 
                             Double apartmentArea, String apartmentStatus, String headResidentId, 
                             String headFullName, LocalDate headDob, String headCccd, 
                             LocalDate moveInDate, List<ResidentDto> residents, List<VehicleDto> vehicles) {
        this.householdId = householdId;
        this.apartmentId = apartmentId;
        this.apartmentNumber = apartmentNumber;
        this.apartmentArea = apartmentArea;
        this.apartmentStatus = apartmentStatus;
        this.headResidentId = headResidentId;
        this.headFullName = headFullName;
        this.headDob = headDob;
        this.headCccd = headCccd;
        this.moveInDate = moveInDate;
        this.residents = residents;
        this.vehicles = vehicles;
    }
    
    // Getters and Setters
    public String getHouseholdId() {
        return householdId;
    }
    
    public void setHouseholdId(String householdId) {
        this.householdId = householdId;
    }
    
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
    
    public Double getApartmentArea() {
        return apartmentArea;
    }
    
    public void setApartmentArea(Double apartmentArea) {
        this.apartmentArea = apartmentArea;
    }
    
    public String getApartmentStatus() {
        return apartmentStatus;
    }
    
    public void setApartmentStatus(String apartmentStatus) {
        this.apartmentStatus = apartmentStatus;
    }
    
    public String getHeadResidentId() {
        return headResidentId;
    }
    
    public void setHeadResidentId(String headResidentId) {
        this.headResidentId = headResidentId;
    }
    
    public String getHeadFullName() {
        return headFullName;
    }
    
    public void setHeadFullName(String headFullName) {
        this.headFullName = headFullName;
    }
    
    public LocalDate getHeadDob() {
        return headDob;
    }
    
    public void setHeadDob(LocalDate headDob) {
        this.headDob = headDob;
    }
    
    public String getHeadCccd() {
        return headCccd;
    }
    
    public void setHeadCccd(String headCccd) {
        this.headCccd = headCccd;
    }
    
    public LocalDate getMoveInDate() {
        return moveInDate;
    }
    
    public void setMoveInDate(LocalDate moveInDate) {
        this.moveInDate = moveInDate;
    }
    
    public List<ResidentDto> getResidents() {
        return residents;
    }
    
    public void setResidents(List<ResidentDto> residents) {
        this.residents = residents;
    }
    
    public List<VehicleDto> getVehicles() {
        return vehicles;
    }
    
    public void setVehicles(List<VehicleDto> vehicles) {
        this.vehicles = vehicles;
    }
} 