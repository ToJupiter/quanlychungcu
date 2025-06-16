package com.bluemoon.model;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "Payments")
public class Payment {
    
    @Id
    @Column(name = "payment_id", length = 50)
    private String paymentId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "household_id")
    private Household household;
    
    @Column(name = "payment_type", length = 100)
    private String paymentType;
    
    @Column(name = "amount")
    private Float amount;
    
    @Column(name = "due_date")
    private LocalDate dueDate;
    
    @Column(name = "payment_date")
    private LocalDate paymentDate;
    
    @Column(name = "status", length = 50)
    private String status;

    // Default constructor
    public Payment() {}

    // Constructor
    public Payment(String paymentId, Household household, String paymentType, Float amount, LocalDate dueDate, LocalDate paymentDate, String status) {
        this.paymentId = paymentId;
        this.household = household;
        this.paymentType = paymentType;
        this.amount = amount;
        this.dueDate = dueDate;
        this.paymentDate = paymentDate;
        this.status = status;
    }

    // Getters and Setters
    public String getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(String paymentId) {
        this.paymentId = paymentId;
    }

    public Household getHousehold() {
        return household;
    }

    public void setHousehold(Household household) {
        this.household = household;
    }

    public String getPaymentType() {
        return paymentType;
    }

    public void setPaymentType(String paymentType) {
        this.paymentType = paymentType;
    }

    public Float getAmount() {
        return amount;
    }

    public void setAmount(Float amount) {
        this.amount = amount;
    }

    public LocalDate getDueDate() {
        return dueDate;
    }

    public void setDueDate(LocalDate dueDate) {
        this.dueDate = dueDate;
    }

    public LocalDate getPaymentDate() {
        return paymentDate;
    }

    public void setPaymentDate(LocalDate paymentDate) {
        this.paymentDate = paymentDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @PrePersist
    protected void onCreate() {
        if (status == null) {
            status = "Unpaid";
        }
    }
} 