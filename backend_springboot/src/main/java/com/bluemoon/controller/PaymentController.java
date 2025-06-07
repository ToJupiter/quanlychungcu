package com.bluemoon.controller;

import com.bluemoon.dto.PaymentDto;
import com.bluemoon.model.Payment;
import com.bluemoon.service.PaymentService;
import com.bluemoon.util.MapperUtil;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/finance")
@CrossOrigin(origins = "*")
public class PaymentController {

    @Autowired
    private PaymentService paymentService;

    @Autowired
    private MapperUtil mapperUtil;

    // POST /api/finance/payments - Create payment record
    @PostMapping("/payments")
    public ResponseEntity<?> createPayment(@Valid @RequestBody PaymentDto paymentDto) {
        try {
            PaymentDto createdPayment = paymentService.createPayment(paymentDto);
            return ResponseEntity.ok(createdPayment);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }

    // GET /api/finance/households/:household_id/payments - Get all payments for a household
    @GetMapping("/households/{household_id}/payments")
    public ResponseEntity<?> getPaymentsByHousehold(@PathVariable("household_id") String householdId) {
        try {
            List<PaymentDto> payments = paymentService.getPaymentsByHousehold(householdId);
            return ResponseEntity.ok(payments);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }

    // GET /api/finance/payments - Get all payments (filterable)
    @GetMapping("/payments")
    public ResponseEntity<?> getAllPayments(@RequestParam(required = false) String status,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) String householdId) {
        try {
            List<PaymentDto> payments = paymentService.getAllPayments(status, startDate, endDate, householdId);
            return ResponseEntity.ok(payments);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }

    // GET /api/finance/payments/:payment_id - Get payment by ID
    @GetMapping("/payments/{payment_id}")
    public ResponseEntity<?> getPaymentById(@PathVariable("payment_id") String paymentId) {
        try {
            PaymentDto payment = paymentService.getPaymentById(paymentId);
            return ResponseEntity.ok(payment);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }

    // PATCH /api/finance/payments/:payment_id/status - Update payment status
    @PatchMapping("/payments/{payment_id}/status")
    public ResponseEntity<?> updatePaymentStatus(@PathVariable("payment_id") String paymentId, 
                                                @RequestBody Map<String, String> request) {
        try {
            String status = request.get("status");
            String paymentDate = request.get("payment_date");
        

            
            Map<String, Object> response = paymentService.updatePaymentStatus(paymentId, status, paymentDate);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }

    // PUT /api/finance/payments/:payment_id - Update payment
    @PutMapping("/payments/{payment_id}")
    public ResponseEntity<PaymentDto> updatePayment(
            @PathVariable String payment_id,
            @Valid @RequestBody PaymentDto paymentDto) {
        Payment payment = mapperUtil.fromPaymentDto(paymentDto);
        Payment updatedPayment = paymentService.updatePayment(Integer.parseInt(payment_id), payment);
        PaymentDto responseDto = mapperUtil.toPaymentDto(updatedPayment);
        return ResponseEntity.ok(responseDto);
    }

    // DELETE /api/finance/payments/:payment_id - Delete payment
    @DeleteMapping("/payments/{payment_id}")
    public ResponseEntity<?> deletePayment(@PathVariable("payment_id") String paymentId) {
        try {
            Map<String, Object> response = paymentService.deletePayment(paymentId);
        return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }

    // GET /api/finance/reports/financial-summary - Generate financial summary report
    @GetMapping("/reports/financial-summary")
    public ResponseEntity<?> getFinancialSummary(@RequestParam(required = true) String startDate,
            @RequestParam(required = true) String endDate) {
        try {
            Map<String, Object> summary = paymentService.getFinancialSummary(startDate, endDate);
            return ResponseEntity.ok(summary);
        } catch (RuntimeException e) {
            String message = e.getMessage();
            if (message.contains("Start date and end date are required")) {
                return ResponseEntity.status(400).body(Map.of("message", message));
            } else {
                return ResponseEntity.status(400).body(Map.of("message", message));
            }
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("message", "Internal server error"));
        }
    }
    
    // GET /api/finance/dashboard/stats - Get basic statistics for dashboard
    @GetMapping("/dashboard/stats")
    public ResponseEntity<?> getDashboardStats() {
        try {
            Map<String, Object> stats = paymentService.getDashboardStats();
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("message", "Failed to get dashboard stats"));
        }
    }
} 