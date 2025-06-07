package com.bluemoon.model;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "Residents")
public class Resident {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "resident_id")
    private Integer residentId;
    
    @Column(name = "household_id")
    private Integer householdId;
    
    @Column(name = "full_name", nullable = false, length = 255)
    private String fullName;
    
    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;
    
    @Column(name = "cccd_number", unique = true, length = 20)
    private String cccdNumber;
    
    @Column(name = "role_in_household", length = 50)
    private String roleInHousehold;
    
    // Relationships
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "household_id", insertable = false, updatable = false)
    private Household household;
    
    // Default constructor
    public Resident() {}
    
    // Constructor
    public Resident(Integer householdId, String fullName, LocalDate dateOfBirth, String cccdNumber, String roleInHousehold) {
        this.householdId = householdId;
        this.fullName = fullName;
        this.dateOfBirth = dateOfBirth;
        this.cccdNumber = cccdNumber;
        this.roleInHousehold = roleInHousehold;
    }
    
    // Getters and Setters
    public Integer getResidentId() {
        return residentId;
    }
    
    public void setResidentId(Integer residentId) {
        this.residentId = residentId;
    }
    
    public Integer getHouseholdId() {
        return householdId;
    }
    
    public void setHouseholdId(Integer householdId) {
        this.householdId = householdId;
    }
    
    public String getFullName() {
        return fullName;
    }
    
    public void setFullName(String fullName) {
        this.fullName = fullName;
    }
    
    public LocalDate getDateOfBirth() {
        return dateOfBirth;
    }
    
    public void setDateOfBirth(LocalDate dateOfBirth) {
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
    
    public Household getHousehold() {
        return household;
    }
    
    public void setHousehold(Household household) {
        this.household = household;
    }
} 