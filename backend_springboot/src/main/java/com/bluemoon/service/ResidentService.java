package com.bluemoon.service;

import com.bluemoon.dto.ResidentDto;
import com.bluemoon.model.Resident;
import com.bluemoon.repository.ResidentRepository;
import com.bluemoon.repository.HouseholdRepository;
import com.bluemoon.util.MapperUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class ResidentService {
    
    @Autowired
    private ResidentRepository residentRepository;
    
    @Autowired
    private HouseholdRepository householdRepository;
    
    @Autowired
    private MapperUtil mapperUtil;
    
    public ResidentDto createResident(String householdId, ResidentDto residentDto) {
        // Check if household exists
        if (!householdRepository.existsById(householdId)) {
            throw new RuntimeException("Household not found");
        }
        
        // Check if CCCD number already exists (if provided)
        if (residentDto.getCccdNumber() != null && !residentDto.getCccdNumber().isEmpty()) {
            if (residentRepository.existsByCccdNumber(residentDto.getCccdNumber())) {
                throw new RuntimeException("CCCD number already exists");
            }
        }
        
        Resident resident = mapperUtil.fromResidentDto(residentDto);
        resident.setHousehold(householdRepository.findById(householdId)
                .orElseThrow(() -> new RuntimeException("Household not found")));
        
        Resident savedResident = residentRepository.save(resident);
        
        return mapperUtil.toResidentDto(savedResident);
    }
    
    public List<ResidentDto> getResidentsByHousehold(String householdId) {
        List<Resident> residents = residentRepository.findByHouseholdId(householdId);
        
        return residents.stream()
                .map(mapperUtil::toResidentDto)
                .collect(Collectors.toList());
    }
    
    public Map<String, Object> updateResident(String id, ResidentDto residentDto) {
        Resident existingResident = residentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Resident not found"));
        
        // Check if CCCD number is being changed and if it already exists
        if (residentDto.getCccdNumber() != null && !residentDto.getCccdNumber().isEmpty()) {
            if (!residentDto.getCccdNumber().equals(existingResident.getCccdNumber()) && 
                residentRepository.existsByCccdNumberAndResidentIdNot(residentDto.getCccdNumber(), id)) {
                throw new RuntimeException("CCCD number already exists");
            }
        }
        
        // Update fields
        existingResident.setFullName(residentDto.getFullName());
        if (residentDto.getDateOfBirth() != null && !residentDto.getDateOfBirth().isEmpty()) {
            existingResident.setDateOfBirth(java.time.LocalDate.parse(residentDto.getDateOfBirth()));
        }
        existingResident.setCccdNumber(residentDto.getCccdNumber());
        existingResident.setRoleInHousehold(residentDto.getRoleInHousehold());
        
        residentRepository.save(existingResident);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Resident updated successfully");
        
        return response;
    }
    
    public Map<String, Object> deleteResident(String id) {
        Resident resident = residentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Resident not found"));
        
        residentRepository.delete(resident);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Resident deleted successfully");
        
        return response;
    }
    
    public Map<String, Object> getResidentStats() {
        Long totalResidents = residentRepository.countTotalResidents();
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("count", totalResidents);
        
        return stats;
    }
} 