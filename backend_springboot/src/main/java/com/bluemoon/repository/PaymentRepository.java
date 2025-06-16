package com.bluemoon.repository;

import com.bluemoon.model.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, String> {
    
    // Find payments by household ID
    @Query("SELECT p FROM Payment p WHERE p.household.householdId = :householdId")
    List<Payment> findByHouseholdId(@Param("householdId") String householdId);
    
    // Find payments by status
    List<Payment> findByStatus(String status);
    
    // Find payments by payment type
    List<Payment> findByPaymentType(String paymentType);
    
    // Find payments by household and status
    @Query("SELECT p FROM Payment p WHERE p.household.householdId = :householdId AND p.status = :status")
    List<Payment> findByHouseholdIdAndStatus(@Param("householdId") String householdId, @Param("status") String status);
    
    // Find overdue payments
    @Query("SELECT p FROM Payment p WHERE p.status = 'Unpaid' AND p.dueDate < :currentDate")
    List<Payment> findOverduePayments(@Param("currentDate") LocalDate currentDate);
    
    // Find payments with household and apartment details
    @Query("SELECT p FROM Payment p " +
           "LEFT JOIN FETCH p.household h " +
           "LEFT JOIN FETCH h.apartment " +
           "WHERE p.paymentId = :paymentId")
    Optional<Payment> findPaymentWithDetails(@Param("paymentId") String paymentId);
    
    // Find payments by date range
    @Query("SELECT p FROM Payment p WHERE " +
           "(:startDate IS NULL OR p.dueDate >= :startDate) AND " +
           "(:endDate IS NULL OR p.dueDate <= :endDate)")
    List<Payment> findPaymentsByDateRange(@Param("startDate") LocalDate startDate, 
                                        @Param("endDate") LocalDate endDate);
    
    // Find payments by multiple filters
    @Query("SELECT p FROM Payment p " +
           "LEFT JOIN p.household h " +
           "LEFT JOIN h.apartment a " +
           "WHERE (:status IS NULL OR p.status = :status) AND " +
           "(:paymentType IS NULL OR p.paymentType = :paymentType) AND " +
           "(:householdId IS NULL OR p.household.householdId = :householdId)")
    List<Payment> findPaymentsByFilters(@Param("status") String status,
                                       @Param("paymentType") String paymentType,
                                       @Param("householdId") String householdId);
    
    // Calculate total amount by status
    @Query("SELECT COALESCE(SUM(p.amount), 0) FROM Payment p WHERE p.status = :status")
    Float calculateTotalAmountByStatus(@Param("status") String status);
    
    // Count payments by status
    @Query("SELECT COUNT(p) FROM Payment p WHERE p.status = :status")
    long countByStatus(@Param("status") String status);

    @Query("SELECT p FROM Payment p " +
           "LEFT JOIN FETCH p.household h " +
           "LEFT JOIN FETCH h.apartment a " +
           "WHERE (:status IS NULL OR :status = '' OR p.status = :status) AND " +
           "(:paymentType IS NULL OR :paymentType = '' OR p.paymentType = :paymentType) AND " +
           "(:startDate IS NULL OR p.dueDate >= :startDate) AND " +
           "(:endDate IS NULL OR p.dueDate <= :endDate)")
    List<Payment> findPaymentsWithDetails(@Param("status") String status,
                                          @Param("paymentType") String paymentType,
                                          @Param("startDate") LocalDate startDate,
                                          @Param("endDate") LocalDate endDate);
    
    @Query("SELECT p FROM Payment p WHERE " +
           "(:householdId IS NULL OR p.household.householdId = :householdId) AND " +
           "(:status IS NULL OR :status = '' OR p.status = :status) AND " +
           "(:paymentType IS NULL OR :paymentType = '' OR p.paymentType = :paymentType)")
    List<Payment> findPaymentsWithFilters(@Param("householdId") String householdId,
                                         @Param("status") String status,
                                         @Param("paymentType") String paymentType);
    
    @Query("SELECT p FROM Payment p " +
           "LEFT JOIN FETCH p.household h " +
           "LEFT JOIN FETCH h.apartment a " +
           "WHERE p.household.householdId = :householdId")
    List<Payment> findPaymentsWithApartmentInfoByHousehold(@Param("householdId") String householdId);
    
    @Query("SELECT p FROM Payment p " +
           "LEFT JOIN FETCH p.household h " +
           "LEFT JOIN FETCH h.apartment a " +
           "WHERE p.paymentId = :paymentId")
    Optional<Payment> findPaymentWithApartmentInfoById(@Param("paymentId") String paymentId);
    
    @Query("SELECT COUNT(p) FROM Payment p WHERE p.status = 'Paid'")
    Long countPaidPayments();
    
    @Query("SELECT COUNT(p) FROM Payment p WHERE p.status = 'Unpaid'")
    Long countUnpaidPayments();
    
    @Query("SELECT COALESCE(SUM(p.amount), 0) FROM Payment p WHERE p.status = 'Paid'")
    Float sumPaidAmount();
    
    @Query("SELECT COALESCE(SUM(p.amount), 0) FROM Payment p WHERE p.status = 'Unpaid'")
    Float sumUnpaidAmount();
    
    @Query("SELECT COALESCE(SUM(p.amount), 0) FROM Payment p")
    Float sumTotalAmount();
    
    @Query("SELECT p.paymentType, COUNT(p), COALESCE(SUM(p.amount), 0) FROM Payment p GROUP BY p.paymentType")
    List<Object[]> getPaymentSummaryByType();
    
    // Date range queries for financial reporting
    @Query("SELECT COUNT(p) FROM Payment p WHERE p.dueDate BETWEEN :startDate AND :endDate")
    Long countPaymentsInDateRange(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    @Query("SELECT COALESCE(SUM(p.amount), 0) FROM Payment p WHERE p.status = 'Paid' AND p.paymentDate BETWEEN :startDate AND :endDate")
    Float sumPaidAmountInDateRange(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    @Query("SELECT COALESCE(SUM(p.amount), 0) FROM Payment p WHERE p.status = 'Unpaid' AND p.dueDate BETWEEN :startDate AND :endDate")
    Float sumUnpaidAmountInDateRange(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    @Query("SELECT COUNT(p) FROM Payment p WHERE p.status = 'Paid' AND p.paymentDate BETWEEN :startDate AND :endDate")
    Long countPaidPaymentsInDateRange(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    @Query("SELECT COUNT(p) FROM Payment p WHERE p.status = 'Unpaid' AND p.dueDate BETWEEN :startDate AND :endDate")
    Long countUnpaidPaymentsInDateRange(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    // Additional methods for analytics
    @Query("SELECT COALESCE(SUM(p.amount), 0) FROM Payment p WHERE p.dueDate BETWEEN :startDate AND :endDate")
    Float sumTotalAmountInDateRange(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    @Query("SELECT COALESCE(SUM(p.amount), 0) FROM Payment p WHERE p.status = 'Unpaid' AND p.dueDate <= :endDate")
    Float sumUnpaidAmountUpToDate(@Param("endDate") LocalDate endDate);
    
    // Monthly revenue analytics
    @Query("SELECT YEAR(p.paymentDate), MONTH(p.paymentDate), COALESCE(SUM(p.amount), 0) " +
           "FROM Payment p WHERE p.status = 'Paid' AND p.paymentDate IS NOT NULL " +
           "GROUP BY YEAR(p.paymentDate), MONTH(p.paymentDate) ORDER BY YEAR(p.paymentDate), MONTH(p.paymentDate)")
    List<Object[]> getMonthlyRevenue();
    
    // Payment type analytics
    @Query("SELECT p.paymentType, COUNT(p), COALESCE(SUM(p.amount), 0), " +
           "COUNT(CASE WHEN p.status = 'Paid' THEN 1 END), " +
           "COUNT(CASE WHEN p.status = 'Unpaid' THEN 1 END) " +
           "FROM Payment p GROUP BY p.paymentType")
    List<Object[]> getPaymentAnalyticsByType();
    
    // Bulk operations for adding payments to all households
    @Query("SELECT h.householdId FROM Household h")
    List<String> findAllHouseholdIds();
} 