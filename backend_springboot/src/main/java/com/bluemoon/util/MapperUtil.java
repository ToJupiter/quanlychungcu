package com.bluemoon.util;

import com.bluemoon.dto.*;
import com.bluemoon.model.*;
import com.bluemoon.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Component
public class MapperUtil {
    
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private static final DateTimeFormatter DATETIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
    
    @Autowired
    private HouseholdRepository householdRepository;
    
    @Autowired
    private ApartmentRepository apartmentRepository;
    
    @Autowired
    private ResidentRepository residentRepository;
    
    // ==================== STAFF MAPPING ====================
    
    /**
     * Convert Staff entity to StaffDto for API responses
     */
    public StaffDto toStaffDto(Staff staff) {
        if (staff == null) {
            return null;
        }
        
        String createdAtStr = staff.getCreatedAt() != null ? 
            staff.getCreatedAt().format(DATETIME_FORMATTER) : null;
            
        return new StaffDto(
            staff.getStaffId(),
            staff.getFullName(),
            staff.getEmail(),
            staff.getPhoneNumber(),
            staff.getStatus(),
            createdAtStr
        );
    }
    
    /**
     * Convert StaffDto to Staff entity for database operations
     */
    public Staff toStaffEntity(StaffDto staffDto) {
        return fromStaffDto(staffDto);
    }
    
    public Staff fromStaffDto(StaffDto staffDto) {
        if (staffDto == null) {
            return null;
        }
        
        Staff staff = new Staff();
        staff.setStaffId(staffDto.getStaffId());
        staff.setFullName(staffDto.getFullName());
        staff.setEmail(staffDto.getEmail());
        staff.setPhoneNumber(staffDto.getPhoneNumber());
        staff.setStatus(staffDto.getStatus());
        
        if (staffDto.getCreatedAt() != null && !staffDto.getCreatedAt().isEmpty()) {
            staff.setCreatedAt(LocalDateTime.parse(staffDto.getCreatedAt(), DATETIME_FORMATTER));
        }
        
        return staff;
    }
    
    // ==================== APARTMENT MAPPING ====================
    
    /**
     * Convert Apartment entity to ApartmentDto
     */
    public ApartmentDto toApartmentDto(Apartment apartment) {
        if (apartment == null) {
            return null;
        }
        
        Double area = apartment.getArea() != null ? apartment.getArea().doubleValue() : null;
        
        return new ApartmentDto(
            apartment.getApartmentId(),
            apartment.getApartmentNumber(),
            area,
            apartment.getStatus()
        );
    }
    
    /**
     * Convert ApartmentDto to Apartment entity
     */
    public Apartment fromApartmentDto(ApartmentDto apartmentDto) {
        if (apartmentDto == null) {
            return null;
        }
        
        Apartment apartment = new Apartment();
        apartment.setApartmentId(apartmentDto.getApartmentId());
        apartment.setApartmentNumber(apartmentDto.getApartmentNumber());
        if (apartmentDto.getArea() != null) {
            apartment.setArea(apartmentDto.getArea().floatValue());
        }
        apartment.setStatus(apartmentDto.getStatus());
        
        return apartment;
    }
    
    // ==================== HOUSEHOLD MAPPING ====================
    
    /**
     * Convert Household entity to HouseholdDto
     */
    public HouseholdDto toHouseholdDto(Household household) {
        if (household == null) {
            return null;
        }
        
        String moveInDateStr = household.getMoveInDate() != null ? 
            household.getMoveInDate().format(DATE_FORMATTER) : null;
            
        // Create basic DTO without accessing lazy relationships
        HouseholdDto dto = new HouseholdDto();
        dto.setHouseholdId(household.getHouseholdId());
        dto.setMoveInDate(moveInDateStr);
        
        // Don't access lazy relationships here - let service layer handle this
        // Initialize empty arrays to prevent null issues
        dto.setResidents(new ArrayList<>());
        dto.setVehicles(new ArrayList<>());
        
        return dto;
    }
    
    /**
     * Convert HouseholdDto to Household entity
     */
    public Household fromHouseholdDto(HouseholdDto householdDto) {
        if (householdDto == null) {
            return null;
        }
        
        Household household = new Household();
        household.setHouseholdId(householdDto.getHouseholdId());
        
        // Set apartment relationship
        if (householdDto.getApartmentId() != null && !householdDto.getApartmentId().isEmpty()) {
            Optional<Apartment> apartment = apartmentRepository.findById(householdDto.getApartmentId());
            apartment.ifPresent(household::setApartment);
        }
        
        // Set head of household relationship
        if (householdDto.getHeadResidentId() != null && !householdDto.getHeadResidentId().isEmpty()) {
            Optional<Resident> headResident = residentRepository.findById(householdDto.getHeadResidentId());
            headResident.ifPresent(household::setHeadOfHousehold);
        }
        
        if (householdDto.getMoveInDate() != null && !householdDto.getMoveInDate().isEmpty()) {
            household.setMoveInDate(LocalDate.parse(householdDto.getMoveInDate(), DATE_FORMATTER));
        }
        
        return household;
    }
    
    // ==================== RESIDENT MAPPING ====================
    
    /**
     * Convert Resident entity to ResidentDto
     */
    public ResidentDto toResidentDto(Resident resident) {
        if (resident == null) {
            return null;
        }
        
        String dobStr = resident.getDateOfBirth() != null ? 
            resident.getDateOfBirth().format(DATE_FORMATTER) : null;
            
        return new ResidentDto(
            resident.getResidentId(),
            resident.getHousehold() != null ? resident.getHousehold().getHouseholdId() : null,
            resident.getFullName(),
            dobStr,
            resident.getCccdNumber(),
            resident.getRoleInHousehold()
        );
    }
    
    /**
     * Convert ResidentDto to Resident entity
     */
    public Resident fromResidentDto(ResidentDto residentDto) {
        if (residentDto == null) {
            return null;
        }
        
        Resident resident = new Resident();
        resident.setResidentId(residentDto.getResidentId());
        
        // Set household relationship
        if (residentDto.getHouseholdId() != null && !residentDto.getHouseholdId().isEmpty()) {
            Optional<Household> household = householdRepository.findById(residentDto.getHouseholdId());
            household.ifPresent(resident::setHousehold);
        }
        
        resident.setFullName(residentDto.getFullName());
        if (residentDto.getDateOfBirth() != null && !residentDto.getDateOfBirth().isEmpty()) {
            resident.setDateOfBirth(LocalDate.parse(residentDto.getDateOfBirth(), DATE_FORMATTER));
        }
        resident.setCccdNumber(residentDto.getCccdNumber());
        resident.setRoleInHousehold(residentDto.getRoleInHousehold());
        
        return resident;
    }
    
    // ==================== VEHICLE MAPPING ====================
    
    /**
     * Convert Vehicle entity to VehicleDto
     */
    public VehicleDto toVehicleDto(Vehicle vehicle) {
        if (vehicle == null) {
            return null;
        }
        
        String regDateStr = vehicle.getRegistrationDate() != null ? 
            vehicle.getRegistrationDate().format(DATE_FORMATTER) : null;
            
        return new VehicleDto(
            vehicle.getVehicleId(),
            vehicle.getHousehold() != null ? vehicle.getHousehold().getHouseholdId() : null,
            vehicle.getPlateNumber(),
            vehicle.getVehicleType(),
            regDateStr
        );
    }
    
    /**
     * Convert VehicleDto to Vehicle entity
     */
    public Vehicle fromVehicleDto(VehicleDto vehicleDto) {
        if (vehicleDto == null) {
            return null;
        }
        
        Vehicle vehicle = new Vehicle();
        vehicle.setVehicleId(vehicleDto.getVehicleId());
        
        // Set household relationship
        if (vehicleDto.getHouseholdId() != null && !vehicleDto.getHouseholdId().isEmpty()) {
            Optional<Household> household = householdRepository.findById(vehicleDto.getHouseholdId());
            household.ifPresent(vehicle::setHousehold);
        }
        
        vehicle.setPlateNumber(vehicleDto.getPlateNumber());
        vehicle.setVehicleType(vehicleDto.getVehicleType());
        if (vehicleDto.getRegistrationDate() != null && !vehicleDto.getRegistrationDate().isEmpty()) {
            vehicle.setRegistrationDate(LocalDate.parse(vehicleDto.getRegistrationDate(), DATE_FORMATTER));
        }
        
        return vehicle;
    }
    
    // ==================== PAYMENT MAPPING ====================
    
    /**
     * Convert Payment entity to PaymentDto
     */
    public PaymentDto toPaymentDto(Payment payment) {
        if (payment == null) {
            return null;
        }
        
        Double amount = payment.getAmount() != null ? payment.getAmount().doubleValue() : null;
        String dueDateStr = payment.getDueDate() != null ? 
            payment.getDueDate().format(DATE_FORMATTER) : null;
        String paymentDateStr = payment.getPaymentDate() != null ? 
            payment.getPaymentDate().format(DATE_FORMATTER) : null;
            
        return new PaymentDto(
            payment.getPaymentId(),
            payment.getHousehold() != null ? payment.getHousehold().getHouseholdId() : null,
            payment.getPaymentType(),
            amount,
            dueDateStr,
            paymentDateStr,
            payment.getStatus()
        );
    }
    
    /**
     * Convert PaymentDto to Payment entity
     */
    public Payment fromPaymentDto(PaymentDto paymentDto) {
        if (paymentDto == null) {
            return null;
        }
        
        Payment payment = new Payment();
        payment.setPaymentId(paymentDto.getPaymentId());
        
        // Set household relationship
        if (paymentDto.getHouseholdId() != null && !paymentDto.getHouseholdId().isEmpty()) {
            Optional<Household> household = householdRepository.findById(paymentDto.getHouseholdId());
            household.ifPresent(payment::setHousehold);
        }
        
        payment.setPaymentType(paymentDto.getPaymentType());
        if (paymentDto.getAmount() != null) {
            payment.setAmount(paymentDto.getAmount().floatValue());
        }
        if (paymentDto.getDueDate() != null && !paymentDto.getDueDate().isEmpty()) {
            payment.setDueDate(LocalDate.parse(paymentDto.getDueDate(), DATE_FORMATTER));
        }
        if (paymentDto.getPaymentDate() != null && !paymentDto.getPaymentDate().isEmpty()) {
            payment.setPaymentDate(LocalDate.parse(paymentDto.getPaymentDate(), DATE_FORMATTER));
        }
        payment.setStatus(paymentDto.getStatus());
        
        return payment;
    }
    
    // ==================== HELPER METHODS ====================
    
    /**
     * Convert list of entities to list of DTOs
     */
    public List<ResidentDto> toResidentDtoList(List<Resident> residents) {
        if (residents == null) {
            return null;
        }
        return residents.stream().map(this::toResidentDto).collect(Collectors.toList());
    }
    
    public List<VehicleDto> toVehicleDtoList(List<Vehicle> vehicles) {
        if (vehicles == null) {
            return null;
        }
        return vehicles.stream().map(this::toVehicleDto).collect(Collectors.toList());
    }
    
    public List<PaymentDto> toPaymentDtoList(List<Payment> payments) {
        if (payments == null) {
            return null;
        }
        return payments.stream().map(this::toPaymentDto).collect(Collectors.toList());
    }
} 