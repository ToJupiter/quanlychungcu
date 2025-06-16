package com.bluemoon.service;

import com.bluemoon.dto.HouseholdDto;
import com.bluemoon.dto.ResidentDto;
import com.bluemoon.dto.VehicleDto;
import com.bluemoon.model.Household;
import com.bluemoon.model.Apartment;
import com.bluemoon.model.Resident;
import com.bluemoon.model.Vehicle;
import com.bluemoon.repository.HouseholdRepository;
import com.bluemoon.repository.ApartmentRepository;
import com.bluemoon.repository.ResidentRepository;
import com.bluemoon.repository.VehicleRepository;
import com.bluemoon.util.MapperUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
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
        String apartmentId = householdDto.getApartmentId();
        Apartment apartment = apartmentRepository.findById(apartmentId)
                .orElseThrow(() -> new RuntimeException("Apartment not found"));
        
        // Check if apartment already has a household
        if (householdRepository.existsByApartmentId(apartmentId)) {
            throw new RuntimeException("Apartment already has a household");
        }
        
        // Create the household entity first
        Household household = new Household();
        household.setHouseholdId(householdDto.getHouseholdId());
        household.setApartment(apartment);
        if (householdDto.getMoveInDate() != null && !householdDto.getMoveInDate().isEmpty()) {
            household.setMoveInDate(java.time.LocalDate.parse(householdDto.getMoveInDate()));
        }
        
        // Save household first to get it persisted
        Household savedHousehold = householdRepository.save(household);
        
        // Process residents from the request
        String headResidentId = null;
        if (householdDto.getResidents() != null && !householdDto.getResidents().isEmpty()) {
            for (int i = 0; i < householdDto.getResidents().size(); i++) {
                ResidentDto residentDto = householdDto.getResidents().get(i);
                
                // Create resident entity
                Resident resident = new Resident();
                resident.setResidentId(residentDto.getResidentId() != null ? 
                    residentDto.getResidentId() : generateUUID());
                resident.setHousehold(savedHousehold);
                resident.setFullName(residentDto.getFullName());
                if (residentDto.getDateOfBirth() != null && !residentDto.getDateOfBirth().isEmpty()) {
                    resident.setDateOfBirth(java.time.LocalDate.parse(residentDto.getDateOfBirth()));
                }
                resident.setCccdNumber(residentDto.getCccdNumber());
                resident.setRoleInHousehold(residentDto.getRoleInHousehold());
                
                // Save resident
                Resident savedResident = residentRepository.save(resident);
                
                // Set the first resident as head of household
                if (i == 0) {
                    headResidentId = savedResident.getResidentId();
                    savedHousehold.setHeadOfHousehold(savedResident);
                }
            }
        }
        
        // Process vehicles from the request
        if (householdDto.getVehicles() != null && !householdDto.getVehicles().isEmpty()) {
            for (VehicleDto vehicleDto : householdDto.getVehicles()) {
                // Create vehicle entity
                Vehicle vehicle = new Vehicle();
                vehicle.setVehicleId(vehicleDto.getVehicleId() != null ? 
                    vehicleDto.getVehicleId() : generateUUID());
                vehicle.setHousehold(savedHousehold);
                vehicle.setPlateNumber(vehicleDto.getPlateNumber());
                vehicle.setVehicleType(vehicleDto.getVehicleType());
                if (vehicleDto.getRegistrationDate() != null && !vehicleDto.getRegistrationDate().isEmpty()) {
                    vehicle.setRegistrationDate(java.time.LocalDate.parse(vehicleDto.getRegistrationDate()));
                }
                
                // Save vehicle
                vehicleRepository.save(vehicle);
            }
        }
        
        // Update household with head resident if we have one
        if (headResidentId != null) {
            householdRepository.save(savedHousehold);
        }
        
        // Update apartment status to occupied
        apartment.setStatus("occupied");
        apartmentRepository.save(apartment);
        
        // Return properly mapped household with all details
        return mapHouseholdWithDetails(savedHousehold);
    }
    
    // Helper method to generate UUID
    private String generateUUID() {
        return java.util.UUID.randomUUID().toString();
    }
    
    public List<HouseholdDto> getAllHouseholds(String apartmentNumber) {
        // Use the query that includes apartment and head resident details (like Node.js backend)
        List<Household> households = householdRepository.findAllHouseholdsWithDetails();
        
        return households.stream()
                .map(this::mapHouseholdWithDetails)
                .collect(Collectors.toList());
    }
    
    private HouseholdDto mapHouseholdWithDetails(Household household) {
        // Get all residents and vehicles for this household
        List<Resident> residents = residentRepository.findByHouseholdId(household.getHouseholdId());
        List<ResidentDto> residentDtos = mapperUtil.toResidentDtoList(residents);
        
        List<VehicleDto> vehicleDtos = mapperUtil.toVehicleDtoList(
            vehicleRepository.findByHouseholdId(household.getHouseholdId())
        );
        
        // Create detailed household DTO manually to avoid lazy loading issues
        HouseholdDto dto = new HouseholdDto();
        dto.setHouseholdId(household.getHouseholdId());
        dto.setMoveInDate(household.getMoveInDate() != null ? 
            household.getMoveInDate().toString() : null);
        
        // Set apartment details - get fresh apartment data if needed
        if (household.getApartment() != null) {
            try {
                dto.setApartmentId(household.getApartment().getApartmentId());
                dto.setApartmentNumber(household.getApartment().getApartmentNumber());
                dto.setApartmentArea(household.getApartment().getArea() != null ? 
                    household.getApartment().getArea().doubleValue() : 0.0);
                dto.setApartmentStatus(household.getApartment().getStatus());
            } catch (Exception e) {
                // If lazy loading fails, fetch apartment separately
                Apartment apartment = apartmentRepository.findById(
                    household.getApartment().getApartmentId()).orElse(null);
                if (apartment != null) {
                    dto.setApartmentId(apartment.getApartmentId());
                    dto.setApartmentNumber(apartment.getApartmentNumber());
                    dto.setApartmentArea(apartment.getArea() != null ? 
                        apartment.getArea().doubleValue() : 0.0);
                    dto.setApartmentStatus(apartment.getStatus());
                }
            }
        } else {
            dto.setApartmentNumber("N/A");
            dto.setApartmentArea(0.0);
            dto.setApartmentStatus("unknown");
        }
        
        // Set head resident details - get fresh head resident data if needed
        if (household.getHeadOfHousehold() != null) {
            try {
                dto.setHeadResidentId(household.getHeadOfHousehold().getResidentId());
                dto.setHeadFullName(household.getHeadOfHousehold().getFullName());
                dto.setHeadDob(household.getHeadOfHousehold().getDateOfBirth() != null ? 
                    household.getHeadOfHousehold().getDateOfBirth().toString() : "1970-01-01");
                dto.setHeadCccd(household.getHeadOfHousehold().getCccdNumber());
            } catch (Exception e) {
                // If lazy loading fails, fetch resident separately
                Resident headResident = residentRepository.findById(
                    household.getHeadOfHousehold().getResidentId()).orElse(null);
                if (headResident != null) {
                    dto.setHeadResidentId(headResident.getResidentId());
                    dto.setHeadFullName(headResident.getFullName());
                    dto.setHeadDob(headResident.getDateOfBirth() != null ? 
                        headResident.getDateOfBirth().toString() : "1970-01-01");
                    dto.setHeadCccd(headResident.getCccdNumber());
                } else {
                    dto.setHeadFullName("N/A");
                    dto.setHeadDob("1970-01-01");
                    dto.setHeadCccd("");
                }
            }
        } else {
            dto.setHeadFullName("N/A");
            dto.setHeadDob("1970-01-01");
            dto.setHeadCccd("");
        }
        
        // Set residents and vehicles arrays with actual data
        dto.setResidents(residentDtos);
        dto.setVehicles(vehicleDtos);
        
        return dto;
    }
    
    public HouseholdDto getHouseholdById(String id) {
        Household household = householdRepository.findHouseholdDetailsById(id)
                .orElseThrow(() -> new RuntimeException("Household not found"));
        
        return mapHouseholdWithDetails(household);
    }
    
    public Map<String, Object> updateHousehold(String id, HouseholdDto householdDto) {
        Household existingHousehold = householdRepository.findHouseholdDetailsById(id)
                .orElseThrow(() -> new RuntimeException("Household not found"));
        
        // Update fields
        if (householdDto.getMoveInDate() != null) {
            existingHousehold.setMoveInDate(java.time.LocalDate.parse(householdDto.getMoveInDate()));
        }
        
        if (householdDto.getHeadResidentId() != null && !householdDto.getHeadResidentId().isEmpty()) {
            Resident headResident = residentRepository.findById(householdDto.getHeadResidentId())
                    .orElseThrow(() -> new RuntimeException("Resident not found"));
            existingHousehold.setHeadOfHousehold(headResident);
        }
        
        householdRepository.save(existingHousehold);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Household updated successfully");
        
        return response;
    }
    
    public Map<String, Object> deleteHousehold(String id) {
        Household household = householdRepository.findHouseholdDetailsById(id)
                .orElseThrow(() -> new RuntimeException("Household not found"));
        
        // Update apartment status to vacant - access apartment safely
        try {
            if (household.getApartment() != null) {
                Apartment apartment = household.getApartment();
                apartment.setStatus("vacant");
                apartmentRepository.save(apartment);
            }
        } catch (Exception e) {
            // If lazy loading fails, find apartment by household's apartment reference
            // Get apartment ID from another source if needed
            System.err.println("Warning: Could not update apartment status during household deletion");
        }
        
        householdRepository.delete(household);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Household deleted successfully");
        
        return response;
    }
    
    public HouseholdDto getHouseholdDetails(String id) {
        Household household = householdRepository.findHouseholdDetailsById(id)
                .orElseThrow(() -> new RuntimeException("Household not found"));
        
        return mapHouseholdWithDetails(household);
    }
    
    public Map<String, Object> getHouseholdStats() {
        Long totalHouseholds = householdRepository.countTotalHouseholds();
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("total", totalHouseholds);
        
        return stats;
    }
} 