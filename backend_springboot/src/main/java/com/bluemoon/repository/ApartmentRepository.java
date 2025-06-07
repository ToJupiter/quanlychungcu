package com.bluemoon.repository;

import com.bluemoon.model.Apartment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ApartmentRepository extends JpaRepository<Apartment, Integer> {
    
    // Find apartment by apartment number
    Optional<Apartment> findByApartmentNumber(String apartmentNumber);
    
    // Find apartments by status
    List<Apartment> findByStatus(String status);
    
    // Check if apartment number exists
    boolean existsByApartmentNumber(String apartmentNumber);
    
    // Find apartments by status and area range
    @Query("SELECT a FROM Apartment a WHERE " +
           "(:status IS NULL OR a.status = :status) AND " +
           "(:minArea IS NULL OR a.area >= :minArea) AND " +
           "(:maxArea IS NULL OR a.area <= :maxArea)")
    List<Apartment> findApartmentsByFilters(@Param("status") String status, 
                                          @Param("minArea") Double minArea, 
                                          @Param("maxArea") Double maxArea);

    @Query("SELECT a FROM Apartment a WHERE " +
           "(:status IS NULL OR a.status = :status) AND " +
           "(:search IS NULL OR :search = '' OR " +
           "LOWER(a.apartmentNumber) LIKE LOWER(CONCAT('%', :search, '%')))")
    List<Apartment> findApartmentsWithFilters(@Param("status") String status, @Param("search") String search);
    
    @Query("SELECT COUNT(a) FROM Apartment a WHERE a.status = 'occupied'")
    Long countOccupiedApartments();
    
    @Query("SELECT COUNT(a) FROM Apartment a WHERE a.status = 'vacant'")
    Long countVacantApartments();
    
    boolean existsByApartmentNumberAndApartmentIdNot(String apartmentNumber, Integer apartmentId);
} 