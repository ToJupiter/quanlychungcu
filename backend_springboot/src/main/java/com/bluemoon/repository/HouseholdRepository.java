package com.bluemoon.repository;

import com.bluemoon.model.Household;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface HouseholdRepository extends JpaRepository<Household, Integer> {
    
    // Find household by apartment ID
    Optional<Household> findByApartmentId(Integer apartmentId);
    
    // Find households with detailed information (joins with apartment and head resident)
    @Query("SELECT h FROM Household h " +
           "LEFT JOIN FETCH h.apartment " +
           "LEFT JOIN FETCH h.headResident " +
           "WHERE h.householdId = :householdId")
    Optional<Household> findHouseholdWithDetails(@Param("householdId") Integer householdId);
    
    // Find all households with basic apartment information
    @Query("SELECT h FROM Household h " +
           "LEFT JOIN FETCH h.apartment")
    List<Household> findAllWithApartments();
    
    // Find households by apartment status
    @Query("SELECT h FROM Household h " +
           "JOIN h.apartment a " +
           "WHERE a.status = :apartmentStatus")
    List<Household> findByApartmentStatus(@Param("apartmentStatus") String apartmentStatus);
    
    // Check if apartment is already occupied
    boolean existsByApartmentId(Integer apartmentId);

    @Query("SELECT h FROM Household h " +
           "JOIN h.apartment a " +
           "WHERE (:apartmentNumber IS NULL OR :apartmentNumber = '' OR " +
           "LOWER(a.apartmentNumber) LIKE LOWER(CONCAT('%', :apartmentNumber, '%')))")
    List<Household> findHouseholdsWithFilters(@Param("apartmentNumber") String apartmentNumber);
    
    @Query("SELECT h, a, r FROM Household h " +
           "LEFT JOIN h.apartment a " +
           "LEFT JOIN Resident r ON r.residentId = h.headOfHouseholdResidentId " +
           "WHERE h.householdId = :householdId")
    List<Object[]> findHouseholdDetailsById(@Param("householdId") Integer householdId);
    
    @Query("SELECT h, a, r FROM Household h " +
           "LEFT JOIN h.apartment a " +
           "LEFT JOIN Resident r ON r.residentId = h.headOfHouseholdResidentId")
    List<Object[]> findAllHouseholdsWithDetails();
    
    @Query("SELECT COUNT(h) FROM Household h")
    Long countTotalHouseholds();
} 