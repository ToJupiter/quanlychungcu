package com.bluemoon.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public class PaymentDto {
    
    @JsonProperty("payment_id")
    private String paymentId;
    
    @JsonProperty("household_id")
    @NotNull(message = "Household ID is required")
    private String householdId;
    
    @JsonProperty("apartment_id")
    private String apartmentId;
    
    @JsonProperty("apartment_number")
    private String apartmentNumber;
    
    @JsonProperty("payment_type")
    @NotBlank(message = "Payment type is required")
    @Size(max = 100, message = "Payment type must not exceed 100 characters")
    private String paymentType;
    
    @JsonProperty("amount")
    @NotNull(message = "Amount is required")
    @Positive(message = "Amount must be positive")
    private Double amount; // Using Double to match Flutter frontend expectations
    
    @JsonProperty("due_date")
    @NotNull(message = "Due date is required")
    private String dueDate; // ISO date string format
    
    @JsonProperty("payment_date")
    private String paymentDate; // ISO date string format, nullable
    
    @JsonProperty("status")
    @Size(max = 50, message = "Status must not exceed 50 characters")
    private String status;
    
    @JsonProperty("notes")
    private String notes; // Additional field that may be used by frontend
    
    // Default constructor
    public PaymentDto() {}
    
    // Constructor for basic payment
    public PaymentDto(String paymentId, String householdId, String paymentType, Double amount, String dueDate, String paymentDate, String status) {
        this.paymentId = paymentId;
        this.householdId = householdId;
        this.paymentType = paymentType;
        this.amount = amount;
        this.dueDate = dueDate;
        this.paymentDate = paymentDate;
        this.status = status;
    }
    
    // Full constructor with apartment info
    public PaymentDto(String paymentId, String householdId, String apartmentId, String apartmentNumber, 
                     String paymentType, Double amount, String dueDate, String paymentDate, String status, String notes) {
        this.paymentId = paymentId;
        this.householdId = householdId;
        this.apartmentId = apartmentId;
        this.apartmentNumber = apartmentNumber;
        this.paymentType = paymentType;
        this.amount = amount;
        this.dueDate = dueDate;
        this.paymentDate = paymentDate;
        this.status = status;
        this.notes = notes;
    }
    
    // Getters and Setters
    public String getPaymentId() {
        return paymentId;
    }
    
    public void setPaymentId(String paymentId) {
        this.paymentId = paymentId;
    }
    
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
    
    public String getPaymentType() {
        return paymentType;
    }
    
    public void setPaymentType(String paymentType) {
        this.paymentType = paymentType;
    }
    
    public Double getAmount() {
        return amount;
    }
    
    public void setAmount(Double amount) {
        this.amount = amount;
    }
    
    public String getDueDate() {
        return dueDate;
    }
    
    public void setDueDate(String dueDate) {
        this.dueDate = dueDate;
    }
    
    public String getPaymentDate() {
        return paymentDate;
    }
    
    public void setPaymentDate(String paymentDate) {
        this.paymentDate = paymentDate;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getNotes() {
        return notes;
    }
    
    public void setNotes(String notes) {
        this.notes = notes;
    }
} 