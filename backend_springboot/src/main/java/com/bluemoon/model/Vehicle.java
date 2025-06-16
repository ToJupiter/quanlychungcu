package com.bluemoon.model;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "Vehicles")
public class Vehicle {
    
    @Id
    @Column(name = "vehicle_id", length = 50)
    private String vehicleId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "household_id")
    private Household household;
    
    @Column(name = "plate_number", nullable = false, unique = true, length = 50)
    private String plateNumber;
    
    @Column(name = "vehicle_type", length = 50)
    private String vehicleType;
    
    @Column(name = "registration_date")
    private LocalDate registrationDate;
    
    // Default constructor
    public Vehicle() {}
    
    // Constructor
    public Vehicle(String vehicleId, Household household, String plateNumber, String vehicleType, LocalDate registrationDate) {
        this.vehicleId = vehicleId;
        this.household = household;
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
    
    public Household getHousehold() {
        return household;
    }
    
    public void setHousehold(Household household) {
        this.household = household;
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
    
    public LocalDate getRegistrationDate() {
        return registrationDate;
    }
    
    public void setRegistrationDate(LocalDate registrationDate) {
        this.registrationDate = registrationDate;
    }
} 