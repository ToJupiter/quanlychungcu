package com.bluemoon.repository;

import com.bluemoon.model.Vehicle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface VehicleRepository extends JpaRepository<Vehicle, String> {
    
    // Find vehicles by household ID
    @Query("SELECT v FROM Vehicle v WHERE v.household.householdId = :householdId")
    List<Vehicle> findByHouseholdId(@Param("householdId") String householdId);
    
    // Find vehicle by plate number
    Optional<Vehicle> findByPlateNumber(String plateNumber);
    
    // Find vehicles by type
    List<Vehicle> findByVehicleType(String vehicleType);
    
    // Check if plate number exists
    boolean existsByPlateNumber(String plateNumber);
    
    // Count vehicles by household
    @Query("SELECT COUNT(v) FROM Vehicle v WHERE v.household.householdId = :householdId")
    long countByHouseholdId(@Param("householdId") String householdId);
    
    // Find vehicles with household details
    @Query("SELECT v FROM Vehicle v " +
           "LEFT JOIN FETCH v.household h " +
           "LEFT JOIN FETCH h.apartment " +
           "WHERE v.vehicleId = :vehicleId")
    Optional<Vehicle> findVehicleWithHouseholdDetails(@Param("vehicleId") String vehicleId);
    
    // Find vehicles by household and type
    @Query("SELECT v FROM Vehicle v WHERE v.household.householdId = :householdId AND v.vehicleType = :vehicleType")
    List<Vehicle> findByHouseholdIdAndVehicleType(@Param("householdId") String householdId, @Param("vehicleType") String vehicleType);
    
    @Query("SELECT v FROM Vehicle v WHERE " +
           "(:householdId IS NULL OR v.household.householdId = :householdId) AND " +
           "(:vehicleType IS NULL OR :vehicleType = '' OR v.vehicleType = :vehicleType) AND " +
           "(:search IS NULL OR :search = '' OR " +
           "LOWER(v.plateNumber) LIKE LOWER(CONCAT('%', :search, '%')))")
    List<Vehicle> findVehiclesWithFilters(@Param("householdId") String householdId, 
                                         @Param("vehicleType") String vehicleType, 
                                         @Param("search") String search);
    
    @Query("SELECT COUNT(v) FROM Vehicle v")
    Long countTotalVehicles();
    
    @Query("SELECT COUNT(v) FROM Vehicle v WHERE v.vehicleType = :vehicleType")
    Long countVehiclesByType(@Param("vehicleType") String vehicleType);
    
    @Query("SELECT h.householdId, COUNT(v) FROM Vehicle v JOIN v.household h GROUP BY h.householdId")
    List<Object[]> countVehiclesByHousehold();
} 