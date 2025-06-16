package com.bluemoon.repository;

import com.bluemoon.model.Resident;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ResidentRepository extends JpaRepository<Resident, String> {
    
    // Find residents by household ID
    @Query("SELECT r FROM Resident r WHERE r.household.householdId = :householdId")
    List<Resident> findByHouseholdId(@Param("householdId") String householdId);
    
    // Find resident by CCCD number
    Optional<Resident> findByCccdNumber(String cccdNumber);
    
    // Find residents by role in household
    List<Resident> findByRoleInHousehold(String roleInHousehold);
    
    // Find residents by household ID and role
    @Query("SELECT r FROM Resident r WHERE r.household.householdId = :householdId AND r.roleInHousehold = :roleInHousehold")
    List<Resident> findByHouseholdIdAndRoleInHousehold(@Param("householdId") String householdId, @Param("roleInHousehold") String roleInHousehold);
    
    // Search residents by name
    List<Resident> findByFullNameContainingIgnoreCase(String fullName);
    
    // Check if CCCD number exists
    boolean existsByCccdNumber(String cccdNumber);
    
    // Count residents by household
    @Query("SELECT COUNT(r) FROM Resident r WHERE r.household.householdId = :householdId")
    long countByHouseholdId(@Param("householdId") String householdId);
    
    // Find residents with household details
    @Query("SELECT r FROM Resident r " +
           "LEFT JOIN FETCH r.household h " +
           "LEFT JOIN FETCH h.apartment " +
           "WHERE r.residentId = :residentId")
    Optional<Resident> findResidentWithHouseholdDetails(@Param("residentId") String residentId);
    
    @Query("SELECT r FROM Resident r WHERE " +
           "(:householdId IS NULL OR r.household.householdId = :householdId) AND " +
           "(:search IS NULL OR :search = '' OR " +
           "LOWER(r.fullName) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(r.cccdNumber) LIKE LOWER(CONCAT('%', :search, '%')))")
    List<Resident> findResidentsWithFilters(@Param("householdId") String householdId, @Param("search") String search);
    
    @Query("SELECT COUNT(r) FROM Resident r")
    Long countTotalResidents();
    
    @Query("SELECT r FROM Resident r WHERE r.household.householdId = :householdId AND r.roleInHousehold = 'Head'")
    Optional<Resident> findHeadOfHousehold(@Param("householdId") String householdId);
    
    boolean existsByCccdNumberAndResidentIdNot(String cccdNumber, String residentId);
} 