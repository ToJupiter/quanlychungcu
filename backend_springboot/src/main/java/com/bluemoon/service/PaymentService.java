package com.bluemoon.service;

import com.bluemoon.dto.PaymentDto;
import com.bluemoon.model.Payment;
import com.bluemoon.model.Household;
import com.bluemoon.model.Apartment;
import com.bluemoon.repository.PaymentRepository;
import com.bluemoon.repository.HouseholdRepository;
import com.bluemoon.util.MapperUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class PaymentService {
    
    @Autowired
    private PaymentRepository paymentRepository;
    
    @Autowired
    private HouseholdRepository householdRepository;
    
    @Autowired
    private MapperUtil mapperUtil;
    
    public PaymentDto createPayment(PaymentDto paymentDto) {
        // Check if household exists
        String householdId = paymentDto.getHouseholdId();
        if (!householdRepository.existsById(householdId)) {
            throw new RuntimeException("Household not found");
        }
        
        Payment payment = mapperUtil.fromPaymentDto(paymentDto);
        payment.setPaymentId(UUID.randomUUID().toString());
        
        // Set default status if not provided
        if (payment.getStatus() == null || payment.getStatus().isEmpty()) {
            payment.setStatus("Unpaid");
        }
        
        Payment savedPayment = paymentRepository.save(payment);
        
        return mapperUtil.toPaymentDto(savedPayment);
    }
    
    @Transactional
    public Map<String, Object> createBulkPayments(String paymentType, Float amount, String dueDateStr) {
        LocalDate dueDate = LocalDate.parse(dueDateStr);
        List<String> householdIds = paymentRepository.findAllHouseholdIds();
        
        if (householdIds.isEmpty()) {
            throw new RuntimeException("No households found in the system");
        }
        
        List<Payment> paymentsToCreate = new ArrayList<>();
        
        for (String householdId : householdIds) {
            Optional<Household> householdOpt = householdRepository.findById(householdId);
            if (householdOpt.isPresent()) {
                Payment payment = new Payment();
                payment.setPaymentId(UUID.randomUUID().toString());
                payment.setHousehold(householdOpt.get());
                payment.setPaymentType(paymentType);
                payment.setAmount(amount);
                payment.setDueDate(dueDate);
                payment.setStatus("Unpaid");
                
                paymentsToCreate.add(payment);
            }
        }
        
        List<Payment> savedPayments = paymentRepository.saveAll(paymentsToCreate);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Bulk payments created successfully");
        response.put("paymentsCreated", savedPayments.size());
        response.put("paymentType", paymentType);
        response.put("amount", amount);
        response.put("dueDate", dueDateStr);
        
        return response;
    }
    
    public List<PaymentDto> getPaymentsByHousehold(String householdId) {
        List<Payment> payments = paymentRepository.findPaymentsWithApartmentInfoByHousehold(householdId);
        
        return payments.stream()
                .map(this::mapPaymentWithApartmentInfo)
                .collect(Collectors.toList());
    }
    
    public List<PaymentDto> getAllPayments(String status, String startDate, String endDate, String householdId) {
        LocalDate start = startDate != null && !startDate.isEmpty() ? LocalDate.parse(startDate) : null;
        LocalDate end = endDate != null && !endDate.isEmpty() ? LocalDate.parse(endDate) : null;
        
        List<Payment> payments = paymentRepository.findPaymentsWithDetails(status, null, start, end);
        
        return payments.stream()
                .map(this::mapPaymentWithApartmentInfo)
                .collect(Collectors.toList());
    }
    
    public PaymentDto getPaymentById(String paymentId) {
        Optional<Payment> paymentOpt = paymentRepository.findPaymentWithApartmentInfoById(paymentId);
        
        if (paymentOpt.isEmpty()) {
            throw new RuntimeException("Payment not found");
        }
        
        return mapPaymentWithApartmentInfo(paymentOpt.get());
    }
    
    public Map<String, Object> updatePaymentStatus(String paymentId, String status, String paymentDate) {
        Payment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new RuntimeException("Payment not found"));
        
        payment.setStatus(status);
        if (paymentDate != null && !paymentDate.isEmpty()) {
            payment.setPaymentDate(LocalDate.parse(paymentDate));
        } else if ("Paid".equals(status)) {
            payment.setPaymentDate(LocalDate.now());
        }
        
        paymentRepository.save(payment);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Payment status updated successfully");
        
        return response;
    }
    
    public PaymentDto updatePayment(String paymentId, PaymentDto paymentDto) {
        Payment existingPayment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new RuntimeException("Payment not found"));
        
        // Update fields
        existingPayment.setPaymentType(paymentDto.getPaymentType());
        existingPayment.setAmount(paymentDto.getAmount().floatValue());
        existingPayment.setDueDate(LocalDate.parse(paymentDto.getDueDate()));
        if (paymentDto.getPaymentDate() != null && !paymentDto.getPaymentDate().isEmpty()) {
            existingPayment.setPaymentDate(LocalDate.parse(paymentDto.getPaymentDate()));
        }
        existingPayment.setStatus(paymentDto.getStatus());
        
        Payment savedPayment = paymentRepository.save(existingPayment);
        return mapperUtil.toPaymentDto(savedPayment);
    }
    
    public Map<String, Object> deletePayment(String paymentId) {
        Payment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new RuntimeException("Payment not found"));
        
        paymentRepository.delete(payment);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Payment deleted successfully");
        
        return response;
    }
    
    public Map<String, Object> getFinancialSummary(String startDate, String endDate) {
        // Requires both startDate and endDate
        if (startDate == null || startDate.isEmpty() || endDate == null || endDate.isEmpty()) {
            throw new RuntimeException("Start date and end date are required for the report.");
        }
        
        LocalDate start = LocalDate.parse(startDate);
        LocalDate end = LocalDate.parse(endDate);
        
        // Financial summary calculations
        Float totalCollected = paymentRepository.sumPaidAmountInDateRange(start, end);
        Float totalDueInPeriod = paymentRepository.sumTotalAmountInDateRange(start, end);
        Float totalOutstandingUnpaid = paymentRepository.sumUnpaidAmountUpToDate(end);
        
        // Create response
        Map<String, Object> summary = new HashMap<>();
        Map<String, String> reportPeriod = new HashMap<>();
        reportPeriod.put("startDate", startDate);
        reportPeriod.put("endDate", endDate);
        
        summary.put("reportPeriod", reportPeriod);
        summary.put("totalCollected", totalCollected != null ? totalCollected.doubleValue() : 0.0);
        summary.put("totalDueInPeriod", totalDueInPeriod != null ? totalDueInPeriod.doubleValue() : 0.0);
        summary.put("totalOutstandingUnpaid", totalOutstandingUnpaid != null ? totalOutstandingUnpaid.doubleValue() : 0.0);
        
        return summary;
    }
    
    public Map<String, Object> getDashboardStats() {
        // Get simple overall statistics for dashboard
        Float totalRevenue = paymentRepository.sumPaidAmount();
        Float totalDue = paymentRepository.sumUnpaidAmount();
        Long totalPayments = (long) paymentRepository.findAll().size();
        Long paidPayments = paymentRepository.countPaidPayments();
        Long unpaidPayments = paymentRepository.countUnpaidPayments();
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalRevenue", totalRevenue != null ? totalRevenue.doubleValue() : 0.0);
        stats.put("totalDue", totalDue != null ? totalDue.doubleValue() : 0.0);
        stats.put("totalPayments", totalPayments);
        stats.put("paidPayments", paidPayments);
        stats.put("unpaidPayments", unpaidPayments);
        
        return stats;
    }
    
    private PaymentDto mapPaymentWithApartmentInfo(Payment payment) {
        PaymentDto dto = mapperUtil.toPaymentDto(payment);
        
        if (payment.getHousehold() != null && payment.getHousehold().getApartment() != null) {
            Apartment apartment = payment.getHousehold().getApartment();
            dto.setApartmentId(apartment.getApartmentId());
            dto.setApartmentNumber(apartment.getApartmentNumber());
        }
        
        return dto;
    }
} 