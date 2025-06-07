package com.bluemoon.repository;

import com.bluemoon.model.Resident;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ResidentRepository extends JpaRepository<Resident, Integer> {
    
    // Find residents by household ID
    List<Resident> findByHouseholdId(Integer householdId);
    
    // Find resident by CCCD number
    Optional<Resident> findByCccdNumber(String cccdNumber);
    
    // Find residents by role in household
    List<Resident> findByRoleInHousehold(String roleInHousehold);
    
    // Find residents by household ID and role
    List<Resident> findByHouseholdIdAndRoleInHousehold(Integer householdId, String roleInHousehold);
    
    // Search residents by name
    List<Resident> findByFullNameContainingIgnoreCase(String fullName);
    
    // Check if CCCD number exists
    boolean existsByCccdNumber(String cccdNumber);
    
    // Count residents by household
    @Query("SELECT COUNT(r) FROM Resident r WHERE r.householdId = :householdId")
    long countByHouseholdId(@Param("householdId") Integer householdId);
    
    // Find residents with household details
    @Query("SELECT r FROM Resident r " +
           "LEFT JOIN FETCH r.household h " +
           "LEFT JOIN FETCH h.apartment " +
           "WHERE r.residentId = :residentId")
    Optional<Resident> findResidentWithHouseholdDetails(@Param("residentId") Integer residentId);
    
    @Query("SELECT r FROM Resident r WHERE " +
           "(:householdId IS NULL OR r.householdId = :householdId) AND " +
           "(:search IS NULL OR :search = '' OR " +
           "LOWER(r.fullName) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(r.cccdNumber) LIKE LOWER(CONCAT('%', :search, '%')))")
    List<Resident> findResidentsWithFilters(@Param("householdId") Integer householdId, @Param("search") String search);
    
    @Query("SELECT COUNT(r) FROM Resident r")
    Long countTotalResidents();
    
    @Query("SELECT r FROM Resident r WHERE r.householdId = :householdId AND r.roleInHousehold = 'Head'")
    Optional<Resident> findHeadOfHousehold(@Param("householdId") Integer householdId);
    
    boolean existsByCccdNumberAndResidentIdNot(String cccdNumber, Integer residentId);
} 