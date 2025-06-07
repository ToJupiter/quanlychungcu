package com.bluemoon.model;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "Apartments")
public class Apartment {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "apartment_id")
    private Integer apartmentId;
    
    @Column(name = "apartment_number", nullable = false, unique = true, length = 50)
    private String apartmentNumber;
    
    @Column(name = "area", precision = 10, scale = 2)
    private BigDecimal area;
    
    @Column(name = "status", length = 50)
    private String status;

    // Default constructor
    public Apartment() {}

    // Constructor
    public Apartment(String apartmentNumber, BigDecimal area, String status) {
        this.apartmentNumber = apartmentNumber;
        this.area = area;
        this.status = status;
    }

    // Getters and Setters
    public Integer getApartmentId() {
        return apartmentId;
    }

    public void setApartmentId(Integer apartmentId) {
        this.apartmentId = apartmentId;
    }

    public String getApartmentNumber() {
        return apartmentNumber;
    }

    public void setApartmentNumber(String apartmentNumber) {
        this.apartmentNumber = apartmentNumber;
    }

    public BigDecimal getArea() {
        return area;
    }

    public void setArea(BigDecimal area) {
        this.area = area;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
} 