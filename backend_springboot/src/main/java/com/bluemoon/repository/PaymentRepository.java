package com.bluemoon.repository;

import com.bluemoon.model.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Integer> {
    
    // Find payments by household ID
    List<Payment> findByHouseholdId(Long householdId);
    
    // Find payments by status
    List<Payment> findByStatus(String status);
    
    // Find payments by payment type
    List<Payment> findByPaymentType(String paymentType);
    
    // Find payments by household and status
    List<Payment> findByHouseholdIdAndStatus(Long householdId, String status);
    
    // Find overdue payments
    @Query("SELECT p FROM Payment p WHERE p.status = 'Unpaid' AND p.dueDate < :currentDate")
    List<Payment> findOverduePayments(@Param("currentDate") LocalDate currentDate);
    
    // Find payments with household and apartment details
    @Query("SELECT p FROM Payment p " +
           "LEFT JOIN FETCH p.household h " +
           "LEFT JOIN FETCH h.apartment " +
           "WHERE p.paymentId = :paymentId")
    Optional<Payment> findPaymentWithDetails(@Param("paymentId") Long paymentId);
    
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
           "(:householdId IS NULL OR p.householdId = :householdId)")
    List<Payment> findPaymentsByFilters(@Param("status") String status,
                                       @Param("paymentType") String paymentType,
                                       @Param("householdId") Long householdId);
    
    // Calculate total amount by status
    @Query("SELECT COALESCE(SUM(p.amount), 0) FROM Payment p WHERE p.status = :status")
    BigDecimal calculateTotalAmountByStatus(@Param("status") String status);
    
    // Count payments by status
    @Query("SELECT COUNT(p) FROM Payment p WHERE p.status = :status")
    long countByStatus(@Param("status") String status);

    @Query("SELECT p, h, a FROM Payment p " +
           "LEFT JOIN Household h ON p.householdId = h.householdId " +
           "LEFT JOIN h.apartment a " +
           "WHERE (:status IS NULL OR :status = '' OR p.status = :status) AND " +
           "(:paymentType IS NULL OR :paymentType = '' OR p.paymentType = :paymentType) AND " +
           "(:startDate IS NULL OR p.dueDate >= :startDate) AND " +
           "(:endDate IS NULL OR p.dueDate <= :endDate)")
    List<Object[]> findPaymentsWithDetails(@Param("status") String status,
                                          @Param("paymentType") String paymentType,
                                          @Param("startDate") LocalDate startDate,
                                          @Param("endDate") LocalDate endDate);
    
    @Query("SELECT p FROM Payment p WHERE " +
           "(:householdId IS NULL OR p.householdId = :householdId) AND " +
           "(:status IS NULL OR :status = '' OR p.status = :status) AND " +
           "(:paymentType IS NULL OR :paymentType = '' OR p.paymentType = :paymentType)")
    List<Payment> findPaymentsWithFilters(@Param("householdId") Long householdId,
                                         @Param("status") String status,
                                         @Param("paymentType") String paymentType);
    
    @Query("SELECT p, h, a FROM Payment p " +
           "LEFT JOIN Household h ON p.householdId = h.householdId " +
           "LEFT JOIN h.apartment a " +
           "WHERE p.householdId = :householdId")
    List<Object[]> findPaymentsWithApartmentInfoByHousehold(@Param("householdId") Integer householdId);
    
    @Query("SELECT p, h, a FROM Payment p " +
           "LEFT JOIN Household h ON p.householdId = h.householdId " +
           "LEFT JOIN h.apartment a " +
           "WHERE p.paymentId = :paymentId")
    List<Object[]> findPaymentWithApartmentInfoById(@Param("paymentId") Integer paymentId);
    
    @Query("SELECT COUNT(p) FROM Payment p WHERE p.status = 'Paid'")
    Long countPaidPayments();
    
    @Query("SELECT COUNT(p) FROM Payment p WHERE p.status = 'Unpaid'")
    Long countUnpaidPayments();
    
    @Query("SELECT SUM(p.amount) FROM Payment p WHERE p.status = 'Paid'")
    BigDecimal sumPaidAmount();
    
    @Query("SELECT SUM(p.amount) FROM Payment p WHERE p.status = 'Unpaid'")
    BigDecimal sumUnpaidAmount();
    
    @Query("SELECT SUM(p.amount) FROM Payment p")
    BigDecimal sumTotalAmount();
    
    @Query("SELECT p.paymentType, COUNT(p), SUM(p.amount) FROM Payment p GROUP BY p.paymentType")
    List<Object[]> getPaymentSummaryByType();
    
    // Date range queries for financial reporting
    @Query("SELECT COUNT(p) FROM Payment p WHERE p.dueDate BETWEEN :startDate AND :endDate")
    Long countPaymentsInDateRange(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    @Query("SELECT SUM(p.amount) FROM Payment p WHERE p.status = 'Paid' AND p.paymentDate BETWEEN :startDate AND :endDate")
    BigDecimal sumPaidAmountInDateRange(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    @Query("SELECT SUM(p.amount) FROM Payment p WHERE p.status = 'Unpaid' AND p.dueDate BETWEEN :startDate AND :endDate")
    BigDecimal sumUnpaidAmountInDateRange(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    @Query("SELECT COUNT(p) FROM Payment p WHERE p.status = 'Paid' AND p.paymentDate BETWEEN :startDate AND :endDate")
    Long countPaidPaymentsInDateRange(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    @Query("SELECT COUNT(p) FROM Payment p WHERE p.status = 'Unpaid' AND p.dueDate BETWEEN :startDate AND :endDate")
    Long countUnpaidPaymentsInDateRange(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    // Additional methods needed for Node.js compatibility
    @Query("SELECT SUM(p.amount) FROM Payment p WHERE p.dueDate BETWEEN :startDate AND :endDate")
    BigDecimal sumTotalAmountInDateRange(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    @Query("SELECT SUM(p.amount) FROM Payment p WHERE p.status = 'Unpaid' AND p.dueDate <= :endDate")
    BigDecimal sumUnpaidAmountUpToDate(@Param("endDate") LocalDate endDate);
} 