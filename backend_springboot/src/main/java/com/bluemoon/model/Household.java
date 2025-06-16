package com.bluemoon.model;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.util.List;

@Entity
@Table(name = "Households")
public class Household {
    
    @Id
    @Column(name = "household_id", length = 50)
    private String householdId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "apartment_id")
    private Apartment apartment;
    
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "head_of_household_resident_id")
    private Resident headOfHousehold;
    
    @Column(name = "move_in_date")
    private LocalDate moveInDate;
    
    @OneToMany(mappedBy = "household", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Resident> residents;
    
    @OneToMany(mappedBy = "household", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Vehicle> vehicles;
    
    @OneToMany(mappedBy = "household", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Payment> payments;

    // Default constructor
    public Household() {}

    // Constructor
    public Household(String householdId, Apartment apartment, Resident headOfHousehold, LocalDate moveInDate) {
        this.householdId = householdId;
        this.apartment = apartment;
        this.headOfHousehold = headOfHousehold;
        this.moveInDate = moveInDate;
    }

    // Getters and Setters
    public String getHouseholdId() {
        return householdId;
    }
    
    public void setHouseholdId(String householdId) {
        this.householdId = householdId;
    }
    
    public Apartment getApartment() {
        return apartment;
    }
    
    public void setApartment(Apartment apartment) {
        this.apartment = apartment;
    }
    
    public Resident getHeadOfHousehold() {
        return headOfHousehold;
    }
    
    public void setHeadOfHousehold(Resident headOfHousehold) {
        this.headOfHousehold = headOfHousehold;
    }
    
    public LocalDate getMoveInDate() {
        return moveInDate;
    }
    
    public void setMoveInDate(LocalDate moveInDate) {
        this.moveInDate = moveInDate;
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
    
    public List<Payment> getPayments() {
        return payments;
    }
    
    public void setPayments(List<Payment> payments) {
        this.payments = payments;
    }
} 