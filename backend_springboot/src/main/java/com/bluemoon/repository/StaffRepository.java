package com.bluemoon.repository;

import com.bluemoon.model.Staff;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StaffRepository extends JpaRepository<Staff, Integer> {
    
    // Find staff by email for authentication
    Optional<Staff> findByEmail(String email);
    
    // Find staff by status
    List<Staff> findByStatus(String status);
    
    // Find staff by full name containing (for search)
    List<Staff> findByFullNameContainingIgnoreCase(String fullName);
    
    // Custom query to search staff by multiple criteria
    @Query("SELECT s FROM Staff s WHERE " +
           "(:status IS NULL OR s.status = :status) AND " +
           "(:search IS NULL OR :search = '' OR " +
           "LOWER(s.fullName) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(s.email) LIKE LOWER(CONCAT('%', :search, '%')))")
    List<Staff> findStaffWithFilters(@Param("status") String status, @Param("search") String search);
    
    @Query("SELECT COUNT(s) FROM Staff s WHERE s.status = 'active'")
    Long countActiveStaff();
    
    // Check if email exists (for validation)
    boolean existsByEmail(String email);
    
    List<Staff> findAllByOrderByCreatedAtDesc();
    
    @Query("SELECT COUNT(s) FROM Staff s WHERE s.status = :status")
    Long countByStatus(@Param("status") String status);
    
    boolean existsByEmailAndStaffIdNot(String email, Integer staffId);
} 