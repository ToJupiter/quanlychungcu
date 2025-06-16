package com.bluemoon.service;

import com.bluemoon.dto.VehicleDto;
import com.bluemoon.model.Vehicle;
import com.bluemoon.repository.VehicleRepository;
import com.bluemoon.repository.HouseholdRepository;
import com.bluemoon.util.MapperUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class VehicleService {
    
    @Autowired
    private VehicleRepository vehicleRepository;
    
    @Autowired
    private HouseholdRepository householdRepository;
    
    @Autowired
    private MapperUtil mapperUtil;
    
    public VehicleDto createVehicle(String householdId, VehicleDto vehicleDto) {
        // Check if household exists
        if (!householdRepository.existsById(householdId)) {
            throw new RuntimeException("Household not found");
        }
        
        // Check if plate number already exists
        if (vehicleRepository.existsByPlateNumber(vehicleDto.getPlateNumber())) {
            throw new RuntimeException("Plate number already exists");
        }
        
        Vehicle vehicle = mapperUtil.fromVehicleDto(vehicleDto);
        vehicle.setHousehold(householdRepository.findById(householdId)
                .orElseThrow(() -> new RuntimeException("Household not found")));
        
        Vehicle savedVehicle = vehicleRepository.save(vehicle);
        
        return mapperUtil.toVehicleDto(savedVehicle);
    }
    
    public List<VehicleDto> getVehiclesByHousehold(String householdId) {
        List<Vehicle> vehicles = vehicleRepository.findByHouseholdId(householdId);
        
        return vehicles.stream()
                .map(mapperUtil::toVehicleDto)
                .collect(Collectors.toList());
    }
    
    public List<VehicleDto> getAllVehicles(String plateNumber, String vehicleType) {
        List<Vehicle> vehicles = vehicleRepository.findVehiclesWithFilters(null, vehicleType, plateNumber);
        
        return vehicles.stream()
                .map(mapperUtil::toVehicleDto)
                .collect(Collectors.toList());
    }
    
    public Map<String, Object> updateVehicle(String id, VehicleDto vehicleDto) {
        Vehicle existingVehicle = vehicleRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Vehicle not found"));
        
        // Check if plate number is being changed and if it already exists
        if (!existingVehicle.getPlateNumber().equals(vehicleDto.getPlateNumber()) && 
            vehicleRepository.existsByPlateNumber(vehicleDto.getPlateNumber())) {
            throw new RuntimeException("Plate number already exists");
        }
        
        // Update fields
        existingVehicle.setPlateNumber(vehicleDto.getPlateNumber());
        existingVehicle.setVehicleType(vehicleDto.getVehicleType());
        if (vehicleDto.getRegistrationDate() != null && !vehicleDto.getRegistrationDate().isEmpty()) {
            existingVehicle.setRegistrationDate(java.time.LocalDate.parse(vehicleDto.getRegistrationDate()));
        }
        
        vehicleRepository.save(existingVehicle);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Vehicle updated successfully");
        
        return response;
    }
    
    public Map<String, Object> deleteVehicle(String id) {
        Vehicle vehicle = vehicleRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Vehicle not found"));
        
        vehicleRepository.delete(vehicle);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Vehicle deleted successfully");
        
        return response;
    }
    
    public Map<String, Object> getVehicleStats() {
        Long totalVehicles = vehicleRepository.count();
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("total", totalVehicles);
        
        return stats;
    }
} 