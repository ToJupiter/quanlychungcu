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

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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
        Integer householdId = Integer.parseInt(paymentDto.getHouseholdId());
        if (!householdRepository.existsById(householdId)) {
            throw new RuntimeException("Household not found");
        }
        
        Payment payment = mapperUtil.fromPaymentDto(paymentDto);
        
        // Set default status if not provided
        if (payment.getStatus() == null || payment.getStatus().isEmpty()) {
            payment.setStatus("Unpaid");
        }
        
        Payment savedPayment = paymentRepository.save(payment);
        
        return mapperUtil.toPaymentDto(savedPayment);
    }
    
    public List<PaymentDto> getPaymentsByHousehold(String householdId) {
        Integer houseId = Integer.parseInt(householdId);
        List<Object[]> results = paymentRepository.findPaymentsWithApartmentInfoByHousehold(houseId);
        
        return results.stream()
                .map(this::mapPaymentWithApartmentInfo)
                .collect(Collectors.toList());
    }
    
    public List<PaymentDto> getAllPayments(String status, String startDate, String endDate, String householdId) {
        LocalDate start = startDate != null && !startDate.isEmpty() ? LocalDate.parse(startDate) : null;
        LocalDate end = endDate != null && !endDate.isEmpty() ? LocalDate.parse(endDate) : null;
        Integer houseId = householdId != null && !householdId.isEmpty() ? Integer.parseInt(householdId) : null;
        
        List<Object[]> results = paymentRepository.findPaymentsWithDetails(status, null, start, end);
        
        return results.stream()
                .map(this::mapPaymentWithApartmentInfo)
                .collect(Collectors.toList());
    }
    
    public PaymentDto getPaymentById(String id) {
        Integer paymentId = Integer.parseInt(id);
        List<Object[]> results = paymentRepository.findPaymentWithApartmentInfoById(paymentId);
        
        if (results.isEmpty()) {
            throw new RuntimeException("Payment not found");
        }
        
        return mapPaymentWithApartmentInfo(results.get(0));
    }
    
    public Map<String, Object> updatePaymentStatus(String id, String status, String paymentDate) {
        Integer paymentId = Integer.parseInt(id);
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
    
    public Payment updatePayment(Integer paymentId, Payment updatedPayment) {
        Payment existingPayment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new RuntimeException("Payment not found"));
        
        // Update fields
        existingPayment.setPaymentType(updatedPayment.getPaymentType());
        existingPayment.setAmount(updatedPayment.getAmount());
        existingPayment.setDueDate(updatedPayment.getDueDate());
        existingPayment.setPaymentDate(updatedPayment.getPaymentDate());
        existingPayment.setStatus(updatedPayment.getStatus());
        
        return paymentRepository.save(existingPayment);
    }
    
    public Map<String, Object> deletePayment(String id) {
        Integer paymentId = Integer.parseInt(id);
        Payment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new RuntimeException("Payment not found"));
        
        paymentRepository.delete(payment);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Payment deleted successfully");
        
        return response;
    }
    
    public Map<String, Object> getFinancialSummary(String startDate, String endDate) {
        // Node.js backend requires both startDate and endDate
        if (startDate == null || startDate.isEmpty() || endDate == null || endDate.isEmpty()) {
            throw new RuntimeException("Start date and end date are required for the report.");
        }
        
        LocalDate start = LocalDate.parse(startDate);
        LocalDate end = LocalDate.parse(endDate);
        
        // Match Node.js backend queries exactly:
        // 1. totalCollected: SUM(amount) WHERE status = 'Paid' AND payment_date BETWEEN start AND end
        BigDecimal totalCollected = paymentRepository.sumPaidAmountInDateRange(start, end);
        
        // 2. totalDueInPeriod: SUM(amount) WHERE due_date BETWEEN start AND end
        BigDecimal totalDueInPeriod = paymentRepository.sumTotalAmountInDateRange(start, end);
        
        // 3. totalOutstandingUnpaid: SUM(amount) WHERE status = 'Unpaid' AND due_date <= end
        BigDecimal totalOutstandingUnpaid = paymentRepository.sumUnpaidAmountUpToDate(end);
        
        // Create response that matches Node.js format exactly
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
        BigDecimal totalRevenue = paymentRepository.sumPaidAmount();
        BigDecimal totalDue = paymentRepository.sumUnpaidAmount();
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
    
    private PaymentDto mapPaymentWithApartmentInfo(Object[] result) {
        Payment payment = (Payment) result[0];
        Household household = result.length > 1 ? (Household) result[1] : null;
        Apartment apartment = result.length > 2 ? (Apartment) result[2] : null;
        
        PaymentDto dto = mapperUtil.toPaymentDto(payment);
        
        if (apartment != null) {
            dto.setApartmentId(apartment.getApartmentId().toString());
            dto.setApartmentNumber(apartment.getApartmentNumber());
        }
        
        return dto;
    }
} 