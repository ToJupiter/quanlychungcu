package com.bluemoon.service;

import com.bluemoon.dto.HouseholdDto;
import com.bluemoon.dto.ResidentDto;
import com.bluemoon.dto.VehicleDto;
import com.bluemoon.model.Household;
import com.bluemoon.model.Apartment;
import com.bluemoon.model.Resident;
import com.bluemoon.repository.HouseholdRepository;
import com.bluemoon.repository.ApartmentRepository;
import com.bluemoon.repository.ResidentRepository;
import com.bluemoon.repository.VehicleRepository;
import com.bluemoon.util.MapperUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class HouseholdService {
    
    @Autowired
    private HouseholdRepository householdRepository;
    
    @Autowired
    private ApartmentRepository apartmentRepository;
    
    @Autowired
    private ResidentRepository residentRepository;
    
    @Autowired
    private VehicleRepository vehicleRepository;
    
    @Autowired
    private MapperUtil mapperUtil;
    
    public HouseholdDto createHousehold(HouseholdDto householdDto) {
        // Check if apartment exists
        Integer apartmentId = Integer.parseInt(householdDto.getApartmentId());
        Apartment apartment = apartmentRepository.findById(apartmentId)
                .orElseThrow(() -> new RuntimeException("Apartment not found"));
        
        // Check if apartment already has a household
        if (householdRepository.existsByApartmentId(apartmentId)) {
            throw new RuntimeException("Apartment already has a household");
        }
        
        Household household = mapperUtil.fromHouseholdDto(householdDto);
        Household savedHousehold = householdRepository.save(household);
        
        // Update apartment status to occupied
        apartment.setStatus("occupied");
        apartmentRepository.save(apartment);
        
        return mapperUtil.toHouseholdDto(savedHousehold);
    }
    
    public List<HouseholdDto> getAllHouseholds(String apartmentNumber) {
        // Use the query that includes apartment and head resident details (like Node.js backend)
        List<Object[]> results = householdRepository.findAllHouseholdsWithDetails();
        
        return results.stream()
                .map(this::mapHouseholdWithDetails)
                .collect(Collectors.toList());
    }
    
    private HouseholdDto mapHouseholdWithDetails(Object[] result) {
        Household household = (Household) result[0];
        Apartment apartment = result.length > 1 ? (Apartment) result[1] : null;
        Resident headResident = result.length > 2 ? (Resident) result[2] : null;
        
        // Get all residents and vehicles for this household
        List<Resident> residents = residentRepository.findByHouseholdId(household.getHouseholdId());
        List<ResidentDto> residentDtos = mapperUtil.toResidentDtoList(residents);
        
        List<VehicleDto> vehicleDtos = mapperUtil.toVehicleDtoList(
            vehicleRepository.findByHouseholdId(household.getHouseholdId())
        );
        
        // Create detailed household DTO that matches Node.js format exactly
        HouseholdDto dto = mapperUtil.toHouseholdDto(household);
        
        // Set apartment details
        if (apartment != null) {
            dto.setApartmentId(apartment.getApartmentId().toString());
            dto.setApartmentNumber(apartment.getApartmentNumber());
            dto.setApartmentArea(apartment.getArea() != null ? apartment.getArea().doubleValue() : 0.0);
            dto.setApartmentStatus(apartment.getStatus());
        } else {
            dto.setApartmentNumber("N/A");
            dto.setApartmentArea(0.0);
            dto.setApartmentStatus("unknown");
        }
        
        // Set head resident details
        if (headResident != null) {
            dto.setHeadResidentId(headResident.getResidentId().toString());
            dto.setHeadFullName(headResident.getFullName());
            dto.setHeadDob(headResident.getDateOfBirth() != null ? 
                headResident.getDateOfBirth().toString() : null);
            dto.setHeadCccd(headResident.getCccdNumber());
        } else {
            dto.setHeadFullName("N/A");
        }
        
        // Set residents and vehicles arrays
        dto.setResidents(residentDtos);
        dto.setVehicles(vehicleDtos);
        
        return dto;
    }
    
    public HouseholdDto getHouseholdById(String id) {
        Integer householdId = Integer.parseInt(id);
        Household household = householdRepository.findById(householdId)
                .orElseThrow(() -> new RuntimeException("Household not found"));
        
        return mapperUtil.toHouseholdDto(household);
    }
    
    public Map<String, Object> updateHousehold(String id, HouseholdDto householdDto) {
        Integer householdId = Integer.parseInt(id);
        Household existingHousehold = householdRepository.findById(householdId)
                .orElseThrow(() -> new RuntimeException("Household not found"));
        
        // Update fields
        if (householdDto.getMoveInDate() != null) {
            existingHousehold.setMoveInDate(java.time.LocalDate.parse(householdDto.getMoveInDate()));
        }
        
        if (householdDto.getHeadResidentId() != null && !householdDto.getHeadResidentId().isEmpty()) {
            existingHousehold.setHeadOfHouseholdResidentId(Integer.parseInt(householdDto.getHeadResidentId()));
        }
        
        householdRepository.save(existingHousehold);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Household updated successfully");
        
        return response;
    }
    
    public Map<String, Object> deleteHousehold(String id) {
        Integer householdId = Integer.parseInt(id);
        Household household = householdRepository.findById(householdId)
                .orElseThrow(() -> new RuntimeException("Household not found"));
        
        // Update apartment status to vacant
        Apartment apartment = apartmentRepository.findById(household.getApartmentId())
                .orElse(null);
        if (apartment != null) {
            apartment.setStatus("vacant");
            apartmentRepository.save(apartment);
        }
        
        householdRepository.delete(household);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Household deleted successfully");
        
        return response;
    }
    
    public HouseholdDto getHouseholdDetails(String id) {
        Integer householdId = Integer.parseInt(id);
        
        List<Object[]> results = householdRepository.findAllHouseholdsWithDetails();
        
        // Find the specific household from results
        for (Object[] result : results) {
            Household household = (Household) result[0];
            if (household.getHouseholdId().equals(householdId)) {
                Apartment apartment = (Apartment) result[1];
                Resident headResident = (Resident) result[2];
                
                // Get all residents and vehicles for this household
                List<Resident> residents = residentRepository.findByHouseholdId(householdId);
                List<ResidentDto> residentDtos = mapperUtil.toResidentDtoList(residents);
                
                List<VehicleDto> vehicleDtos = mapperUtil.toVehicleDtoList(
                    vehicleRepository.findByHouseholdId(householdId)
                );
                
                // Create detailed household DTO
                HouseholdDto dto = mapperUtil.toHouseholdDto(household);
                if (apartment != null) {
                    dto.setApartmentNumber(apartment.getApartmentNumber());
                    dto.setApartmentArea(apartment.getArea() != null ? apartment.getArea().doubleValue() : null);
                    dto.setApartmentStatus(apartment.getStatus());
                }
                if (headResident != null) {
                    dto.setHeadResidentId(headResident.getResidentId().toString());
                    dto.setHeadFullName(headResident.getFullName());
                    dto.setHeadDob(headResident.getDateOfBirth() != null ? 
                        headResident.getDateOfBirth().toString() : null);
                    dto.setHeadCccd(headResident.getCccdNumber());
                }
                dto.setResidents(residentDtos);
                dto.setVehicles(vehicleDtos);
                
                return dto;
            }
        }
        
        throw new RuntimeException("Household not found");
    }
    
    public Map<String, Object> getHouseholdStats() {
        Long totalHouseholds = householdRepository.countTotalHouseholds();
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("total", totalHouseholds);
        
        return stats;
    }
} 