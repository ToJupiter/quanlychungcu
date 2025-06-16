package com.bluemoon.model;

import jakarta.persistence.*;

@Entity
@Table(name = "Apartments")
public class Apartment {
    
    @Id
    @Column(name = "apartment_id", length = 50)
    private String apartmentId;
    
    @Column(name = "apartment_number", nullable = false, unique = true, length = 50)
    private String apartmentNumber;
    
    @Column(name = "area")
    private Float area;
    
    @Column(name = "status", length = 50)
    private String status;

    // Default constructor
    public Apartment() {}

    // Constructor
    public Apartment(String apartmentId, String apartmentNumber, Float area, String status) {
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

    public Float getArea() {
        return area;
    }

    public void setArea(Float area) {
        this.area = area;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
} 