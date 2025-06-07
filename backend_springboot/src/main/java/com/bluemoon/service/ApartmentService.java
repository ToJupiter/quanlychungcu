package com.bluemoon.service;

import com.bluemoon.dto.ApartmentDto;
import com.bluemoon.model.Apartment;
import com.bluemoon.repository.ApartmentRepository;
import com.bluemoon.repository.HouseholdRepository;
import com.bluemoon.util.MapperUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class ApartmentService {
    
    @Autowired
    private ApartmentRepository apartmentRepository;
    
    @Autowired
    private HouseholdRepository householdRepository;
    
    @Autowired
    private MapperUtil mapperUtil;
    
    public ApartmentDto createApartment(ApartmentDto apartmentDto) {
        // Check if apartment number already exists
        if (apartmentRepository.existsByApartmentNumber(apartmentDto.getApartmentNumber())) {
            throw new RuntimeException("Apartment number already exists");
        }
        
        Apartment apartment = mapperUtil.fromApartmentDto(apartmentDto);
        Apartment savedApartment = apartmentRepository.save(apartment);
        
        return mapperUtil.toApartmentDto(savedApartment);
    }
    
    public List<ApartmentDto> getAllApartments(String status, String search) {
        List<Apartment> apartments = apartmentRepository.findApartmentsWithFilters(status, search);
        
        return apartments.stream()
                .map(mapperUtil::toApartmentDto)
                .collect(Collectors.toList());
    }
    
    public ApartmentDto getApartmentById(String id) {
        Integer apartmentId = Integer.parseInt(id);
        Apartment apartment = apartmentRepository.findById(apartmentId)
                .orElseThrow(() -> new RuntimeException("Apartment not found"));
        
        return mapperUtil.toApartmentDto(apartment);
    }
    
    public Map<String, Object> updateApartment(String id, ApartmentDto apartmentDto) {
        Integer apartmentId = Integer.parseInt(id);
        Apartment existingApartment = apartmentRepository.findById(apartmentId)
                .orElseThrow(() -> new RuntimeException("Apartment not found"));
        
        // Check if apartment number is being changed and if it already exists
        if (!existingApartment.getApartmentNumber().equals(apartmentDto.getApartmentNumber()) && 
            apartmentRepository.existsByApartmentNumberAndApartmentIdNot(apartmentDto.getApartmentNumber(), apartmentId)) {
            throw new RuntimeException("Apartment number already exists");
        }
        
        // Update fields
        existingApartment.setApartmentNumber(apartmentDto.getApartmentNumber());
        if (apartmentDto.getArea() != null) {
            existingApartment.setArea(java.math.BigDecimal.valueOf(apartmentDto.getArea()));
        }
        existingApartment.setStatus(apartmentDto.getStatus());
        
        apartmentRepository.save(existingApartment);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Apartment updated successfully");
        
        return response;
    }
    
    public Map<String, Object> deleteApartment(String id) {
        Integer apartmentId = Integer.parseInt(id);
        Apartment apartment = apartmentRepository.findById(apartmentId)
                .orElseThrow(() -> new RuntimeException("Apartment not found"));
        
        // Check if apartment is occupied (has household)
        // This would require checking household repository, but for now we'll allow deletion
        
        apartmentRepository.delete(apartment);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Apartment deleted successfully");
        
        return response;
    }
    
    public Map<String, Object> getApartmentStats() {
        Long totalApartments = apartmentRepository.count();
        Long occupiedApartments = apartmentRepository.countOccupiedApartments();
        Long vacantApartments = apartmentRepository.countVacantApartments();
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("total", totalApartments);
        stats.put("occupied", occupiedApartments);
        stats.put("vacant", vacantApartments);
        
        return stats;
    }
} 