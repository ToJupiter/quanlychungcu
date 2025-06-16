package com.bluemoon.controller;

import com.bluemoon.service.AnalyticsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.Map;

@RestController
@RequestMapping("/api/analytics")
@CrossOrigin(origins = "*")
public class AnalyticsController {

    @Autowired
    private AnalyticsService analyticsService;

    // Dashboard analytics - accessible to both Admin and Accountant
    @GetMapping("/dashboard")
    @PreAuthorize("hasRole('ADMIN') or hasRole('ACCOUNTANT')")
    public ResponseEntity<Map<String, Object>> getDashboardAnalytics() {
        try {
            Map<String, Object> analytics = analyticsService.getDashboardAnalytics();
            return ResponseEntity.ok(analytics);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    // Financial analytics - accessible to both Admin and Accountant
    @GetMapping("/financial/overview")
    @PreAuthorize("hasRole('ADMIN') or hasRole('ACCOUNTANT')")
    public ResponseEntity<Map<String, Object>> getFinancialOverview() {
        try {
            Map<String, Object> overview = analyticsService.getFinancialOverview();
            return ResponseEntity.ok(overview);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/financial/monthly-revenue")
    @PreAuthorize("hasRole('ADMIN') or hasRole('ACCOUNTANT')")
    public ResponseEntity<?> getMonthlyRevenue() {
        try {
            return ResponseEntity.ok(analyticsService.getMonthlyRevenue());
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/financial/payment-types")
    @PreAuthorize("hasRole('ADMIN') or hasRole('ACCOUNTANT')")
    public ResponseEntity<?> getPaymentTypeAnalytics() {
        try {
            return ResponseEntity.ok(analyticsService.getPaymentTypeAnalytics());
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/financial/date-range")
    @PreAuthorize("hasRole('ADMIN') or hasRole('ACCOUNTANT')")
    public ResponseEntity<Map<String, Object>> getFinancialAnalyticsByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        try {
            Map<String, Object> analytics = analyticsService.getFinancialAnalyticsByDateRange(startDate, endDate);
            return ResponseEntity.ok(analytics);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    // General analytics - accessible to both Admin and Accountant
    @GetMapping("/general/overview")
    @PreAuthorize("hasRole('ADMIN') or hasRole('ACCOUNTANT')")
    public ResponseEntity<Map<String, Object>> getGeneralOverview() {
        try {
            Map<String, Object> overview = analyticsService.getGeneralOverview();
            return ResponseEntity.ok(overview);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/general/vehicles")
    @PreAuthorize("hasRole('ADMIN') or hasRole('ACCOUNTANT')")
    public ResponseEntity<?> getVehicleAnalytics() {
        try {
            return ResponseEntity.ok(analyticsService.getVehicleAnalytics());
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/general/household-vehicles")
    @PreAuthorize("hasRole('ADMIN') or hasRole('ACCOUNTANT')")
    public ResponseEntity<?> getHouseholdVehicleDistribution() {
        try {
            return ResponseEntity.ok(analyticsService.getHouseholdVehicleDistribution());
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
} 