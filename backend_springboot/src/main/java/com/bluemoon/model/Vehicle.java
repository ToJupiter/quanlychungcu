package com.bluemoon.model;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "Vehicles")
public class Vehicle {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "vehicle_id")
    private Integer vehicleId;
    
    @Column(name = "household_id")
    private Integer householdId;
    
    @Column(name = "plate_number", nullable = false, unique = true, length = 50)
    private String plateNumber;
    
    @Column(name = "vehicle_type", length = 50)
    private String vehicleType;
    
    @Column(name = "registration_date")
    private LocalDate registrationDate;
    
    // Relationships
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "household_id", insertable = false, updatable = false)
    private Household household;
    
    // Default constructor
    public Vehicle() {}
    
    // Constructor
    public Vehicle(Integer householdId, String plateNumber, String vehicleType, LocalDate registrationDate) {
        this.householdId = householdId;
        this.plateNumber = plateNumber;
        this.vehicleType = vehicleType;
        this.registrationDate = registrationDate;
    }
    
    // Getters and Setters
    public Integer getVehicleId() {
        return vehicleId;
    }
    
    public void setVehicleId(Integer vehicleId) {
        this.vehicleId = vehicleId;
    }
    
    public Integer getHouseholdId() {
        return householdId;
    }
    
    public void setHouseholdId(Integer householdId) {
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
    
    public LocalDate getRegistrationDate() {
        return registrationDate;
    }
    
    public void setRegistrationDate(LocalDate registrationDate) {
        this.registrationDate = registrationDate;
    }
    
    public Household getHousehold() {
        return household;
    }
    
    public void setHousehold(Household household) {
        this.household = household;
    }
} 