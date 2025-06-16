package com.bluemoon.service;

import com.bluemoon.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.Year;
import java.util.*;

@Service
public class AnalyticsService {

    @Autowired
    private PaymentRepository paymentRepository;

    @Autowired
    private ApartmentRepository apartmentRepository;

    @Autowired
    private HouseholdRepository householdRepository;

    @Autowired
    private VehicleRepository vehicleRepository;

    @Autowired
    private ResidentRepository residentRepository;

    @Autowired
    private StaffRepository staffRepository;

    // Financial Analytics
    public Map<String, Object> getFinancialOverview() {
        Map<String, Object> overview = new HashMap<>();
        
        Float totalRevenue = paymentRepository.sumPaidAmount();
        Float totalPending = paymentRepository.sumUnpaidAmount();
        Long paidCount = paymentRepository.countPaidPayments();
        Long unpaidCount = paymentRepository.countUnpaidPayments();
        
        overview.put("totalRevenue", totalRevenue != null ? totalRevenue : 0.0f);
        overview.put("totalDue", totalPending != null ? totalPending : 0.0f);
        overview.put("paidPayments", paidCount != null ? paidCount : 0L);
        overview.put("unpaidPayments", unpaidCount != null ? unpaidCount : 0L);
        overview.put("totalPayments", (paidCount != null ? paidCount : 0L) + (unpaidCount != null ? unpaidCount : 0L));
        
        return overview;
    }

    public List<Map<String, Object>> getMonthlyRevenue() {
        List<Object[]> monthlyData = paymentRepository.getMonthlyRevenue();
        List<Map<String, Object>> result = new ArrayList<>();
        
        for (Object[] row : monthlyData) {
            Map<String, Object> monthData = new HashMap<>();
            monthData.put("month", String.format("%d-%02d", (Integer) row[0], (Integer) row[1]));
            monthData.put("revenue", row[2] != null ? ((Number) row[2]).doubleValue() : 0.0);
            result.add(monthData);
        }
        
        return result;
    }

    public List<Map<String, Object>> getPaymentTypeAnalytics() {
        List<Object[]> typeData = paymentRepository.getPaymentAnalyticsByType();
        List<Map<String, Object>> result = new ArrayList<>();
        
        for (Object[] row : typeData) {
            Map<String, Object> typeAnalytics = new HashMap<>();
            typeAnalytics.put("payment_type", row[0]);
            typeAnalytics.put("total", row[2] != null ? ((Number) row[2]).doubleValue() : 0.0);
            typeAnalytics.put("totalCount", row[1]);
            typeAnalytics.put("paidCount", row[3]);
            typeAnalytics.put("unpaidCount", row[4]);
            result.add(typeAnalytics);
        }
        
        return result;
    }

    public Map<String, Object> getFinancialAnalyticsByDateRange(LocalDate startDate, LocalDate endDate) {
        Map<String, Object> analytics = new HashMap<>();
        
        Float paidAmount = paymentRepository.sumPaidAmountInDateRange(startDate, endDate);
        Float unpaidAmount = paymentRepository.sumUnpaidAmountInDateRange(startDate, endDate);
        Long paidCount = paymentRepository.countPaidPaymentsInDateRange(startDate, endDate);
        Long unpaidCount = paymentRepository.countUnpaidPaymentsInDateRange(startDate, endDate);
        
        analytics.put("startDate", startDate);
        analytics.put("endDate", endDate);
        analytics.put("paidAmount", paidAmount != null ? paidAmount : 0.0f);
        analytics.put("unpaidAmount", unpaidAmount != null ? unpaidAmount : 0.0f);
        analytics.put("paidCount", paidCount != null ? paidCount : 0L);
        analytics.put("unpaidCount", unpaidCount != null ? unpaidCount : 0L);
        analytics.put("totalAmount", (paidAmount != null ? paidAmount : 0.0f) + (unpaidAmount != null ? unpaidAmount : 0.0f));
        analytics.put("totalCount", (paidCount != null ? paidCount : 0L) + (unpaidCount != null ? unpaidCount : 0L));
        
        return analytics;
    }

    // General Analytics
    public Map<String, Object> getGeneralOverview() {
        Map<String, Object> overview = new HashMap<>();
        
        Long totalApartments = apartmentRepository.countTotalApartments();
        Long occupiedApartments = apartmentRepository.countOccupiedApartments();
        Long vacantApartments = apartmentRepository.countVacantApartments();
        Long totalHouseholds = householdRepository.countTotalHouseholds();
        Long totalResidents = residentRepository.countTotalResidents();
        Long totalVehicles = vehicleRepository.countTotalVehicles();
        Long totalStaff = staffRepository.countActiveStaff();
        Long adminCount = staffRepository.countByRoles(0);
        Long accountantCount = staffRepository.countByRoles(1);
        
        overview.put("totalApartments", totalApartments != null ? totalApartments : 0L);
        overview.put("occupiedApartments", occupiedApartments != null ? occupiedApartments : 0L);
        overview.put("vacantApartments", vacantApartments != null ? vacantApartments : 0L);
        overview.put("totalHouseholds", totalHouseholds != null ? totalHouseholds : 0L);
        overview.put("totalResidents", totalResidents != null ? totalResidents : 0L);
        overview.put("totalVehicles", totalVehicles != null ? totalVehicles : 0L);
        overview.put("totalStaff", totalStaff != null ? totalStaff : 0L);
        overview.put("adminCount", adminCount != null ? adminCount : 0L);
        overview.put("accountantCount", accountantCount != null ? accountantCount : 0L);
        
        // Calculate occupancy rate
        if (totalApartments != null && totalApartments > 0) {
            double occupancyRate = (double) (occupiedApartments != null ? occupiedApartments : 0L) / totalApartments * 100;
            overview.put("occupancyRate", Math.round(occupancyRate * 100.0) / 100.0);
        } else {
            overview.put("occupancyRate", 0.0);
        }
        
        return overview;
    }

    public Map<String, Object> getVehicleAnalytics() {
        Map<String, Object> result = new HashMap<>();
        
        // Total vehicles count
        Long totalVehicles = vehicleRepository.countTotalVehicles();
        result.put("totalVehicles", totalVehicles != null ? totalVehicles : 0L);
        
        // Vehicle types breakdown
        List<Map<String, Object>> vehicleTypes = new ArrayList<>();
        String[] types = {"Car", "Motorbike", "Bicycle", "Truck", "Other"};
        
        for (String type : types) {
            Long count = vehicleRepository.countVehiclesByType(type);
            Map<String, Object> vehicleData = new HashMap<>();
            vehicleData.put("type", type);
            vehicleData.put("count", count != null ? count : 0L);
            vehicleTypes.add(vehicleData);
        }
        
        result.put("vehicleTypes", vehicleTypes);
        
        return result;
    }

    public List<Map<String, Object>> getHouseholdVehicleDistribution() {
        List<Object[]> vehicleDistribution = vehicleRepository.countVehiclesByHousehold();
        List<Map<String, Object>> result = new ArrayList<>();
        
        Map<Integer, Integer> distribution = new HashMap<>();
        for (Object[] row : vehicleDistribution) {
            Long count = (Long) row[1];
            int vehicleCount = count.intValue();
            distribution.put(vehicleCount, distribution.getOrDefault(vehicleCount, 0) + 1);
        }
        
        // Convert to result format
        for (Map.Entry<Integer, Integer> entry : distribution.entrySet()) {
            Map<String, Object> data = new HashMap<>();
            data.put("vehicleCount", entry.getKey());
            data.put("householdCount", entry.getValue());
            result.add(data);
        }
        
        // Sort by vehicle count
        result.sort((a, b) -> Integer.compare((Integer) a.get("vehicleCount"), (Integer) b.get("vehicleCount")));
        
        return result;
    }

    public Map<String, Object> getDashboardAnalytics() {
        Map<String, Object> dashboard = new HashMap<>();
        
        // Get financial and general data
        Map<String, Object> financial = getFinancialOverview();
        Map<String, Object> general = getGeneralOverview();
        
        // Return flat structure that frontend expects
        dashboard.put("totalHouseholds", general.get("totalHouseholds"));
        dashboard.put("totalResidents", general.get("totalResidents"));
        dashboard.put("totalVehicles", general.get("totalVehicles"));
        dashboard.put("totalPayments", financial.get("totalPayments"));
        dashboard.put("totalRevenue", financial.get("totalRevenue"));
        
        // Add additional useful stats
        dashboard.put("totalApartments", general.get("totalApartments"));
        dashboard.put("occupiedApartments", general.get("occupiedApartments"));
        dashboard.put("vacantApartments", general.get("vacantApartments"));
        dashboard.put("paidPayments", financial.get("paidPayments"));
        dashboard.put("unpaidPayments", financial.get("unpaidPayments"));
        dashboard.put("occupancyRate", general.get("occupancyRate"));
        
        return dashboard;
    }

    private String getMonthName(Integer month) {
        if (month == null) return "Unknown";
        String[] months = {"", "January", "February", "March", "April", "May", "June",
                          "July", "August", "September", "October", "November", "December"};
        return month >= 1 && month <= 12 ? months[month] : "Unknown";
    }
} 