package com.bluemoon.model;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.util.List;

@Entity
@Table(name = "Households")
public class Household {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "household_id")
    private Integer householdId;
    
    @Column(name = "apartment_id", unique = true)
    private Integer apartmentId;
    
    @Column(name = "head_of_household_resident_id")
    private Integer headOfHouseholdResidentId;
    
    @Column(name = "move_in_date")
    private LocalDate moveInDate;
    
    // Relationships
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "apartment_id", insertable = false, updatable = false)
    private Apartment apartment;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "head_of_household_resident_id", insertable = false, updatable = false)
    private Resident headResident;
    
    @OneToMany(mappedBy = "householdId", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Resident> residents;
    
    @OneToMany(mappedBy = "householdId", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Vehicle> vehicles;
    
    // Default constructor
    public Household() {}
    
    // Constructor
    public Household(Integer apartmentId, Integer headOfHouseholdResidentId, LocalDate moveInDate) {
        this.apartmentId = apartmentId;
        this.headOfHouseholdResidentId = headOfHouseholdResidentId;
        this.moveInDate = moveInDate;
    }
    
    // Getters and Setters
    public Integer getHouseholdId() {
        return householdId;
    }
    
    public void setHouseholdId(Integer householdId) {
        this.householdId = householdId;
    }
    
    public Integer getApartmentId() {
        return apartmentId;
    }
    
    public void setApartmentId(Integer apartmentId) {
        this.apartmentId = apartmentId;
    }
    
    public Integer getHeadOfHouseholdResidentId() {
        return headOfHouseholdResidentId;
    }
    
    public void setHeadOfHouseholdResidentId(Integer headOfHouseholdResidentId) {
        this.headOfHouseholdResidentId = headOfHouseholdResidentId;
    }
    
    public LocalDate getMoveInDate() {
        return moveInDate;
    }
    
    public void setMoveInDate(LocalDate moveInDate) {
        this.moveInDate = moveInDate;
    }
    
    public Apartment getApartment() {
        return apartment;
    }
    
    public void setApartment(Apartment apartment) {
        this.apartment = apartment;
    }
    
    public List<Resident> getResidents() {
        return residents;
    }
    
    public void setResidents(List<Resident> residents) {
        this.residents = residents;
    }
    
    public List<Vehicle> getVehicles() {
        return vehicles;
    }
    
    public void setVehicles(List<Vehicle> vehicles) {
        this.vehicles = vehicles;
    }
    
    public Resident getHeadResident() {
        return headResident;
    }
    
    public void setHeadResident(Resident headResident) {
        this.headResident = headResident;
    }
} 