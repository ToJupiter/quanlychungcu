package com.bluemoon.util;

import com.bluemoon.dto.*;
import com.bluemoon.model.*;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class MapperUtil {
    
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private static final DateTimeFormatter DATETIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
    
    // ==================== STAFF MAPPING ====================
    
    /**
     * Convert Staff entity to StaffDto for API responses
     * Ensures ID is converted to String for frontend compatibility
     */
    public StaffDto toStaffDto(Staff staff) {
        if (staff == null) {
            return null;
        }
        
        String createdAtStr = staff.getCreatedAt() != null ? 
            staff.getCreatedAt().format(DATETIME_FORMATTER) : null;
            
        return new StaffDto(
            staff.getStaffId() != null ? staff.getStaffId().toString() : null,
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
        
        // Convert String ID to Long if present
        if (staffDto.getStaffId() != null && !staffDto.getStaffId().isEmpty()) {
            try {
                staff.setStaffId(Integer.parseInt(staffDto.getStaffId()));
            } catch (NumberFormatException e) {
                staff.setStaffId(null);
            }
        }
        
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
     * Ensures proper type conversion: Long->String for ID, BigDecimal->Double for area
     */
    public ApartmentDto toApartmentDto(Apartment apartment) {
        if (apartment == null) {
            return null;
        }
        
        Double area = apartment.getArea() != null ? apartment.getArea().doubleValue() : null;
        
        return new ApartmentDto(
            apartment.getApartmentId() != null ? apartment.getApartmentId().toString() : null,
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
        
        if (apartmentDto.getApartmentId() != null && !apartmentDto.getApartmentId().isEmpty()) {
            try {
                apartment.setApartmentId(Integer.parseInt(apartmentDto.getApartmentId()));
            } catch (NumberFormatException e) {
                apartment.setApartmentId(null);
            }
        }
        
        apartment.setApartmentNumber(apartmentDto.getApartmentNumber());
        if (apartmentDto.getArea() != null) {
            apartment.setArea(BigDecimal.valueOf(apartmentDto.getArea()));
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
            
        return new HouseholdDto(
            household.getHouseholdId() != null ? household.getHouseholdId().toString() : null,
            household.getApartmentId() != null ? household.getApartmentId().toString() : null,
            moveInDateStr
        );
    }
    
    /**
     * Convert HouseholdDto to Household entity
     */
    public Household fromHouseholdDto(HouseholdDto householdDto) {
        if (householdDto == null) {
            return null;
        }
        
        Household household = new Household();
        
        if (householdDto.getHouseholdId() != null && !householdDto.getHouseholdId().isEmpty()) {
            try {
                household.setHouseholdId(Integer.parseInt(householdDto.getHouseholdId()));
            } catch (NumberFormatException e) {
                household.setHouseholdId(null);
            }
        }
        
        if (householdDto.getApartmentId() != null && !householdDto.getApartmentId().isEmpty()) {
            try {
                household.setApartmentId(Integer.parseInt(householdDto.getApartmentId()));
            } catch (NumberFormatException e) {
                household.setApartmentId(null);
            }
        }
        
        if (householdDto.getHeadResidentId() != null && !householdDto.getHeadResidentId().isEmpty()) {
            try {
                household.setHeadOfHouseholdResidentId(Integer.parseInt(householdDto.getHeadResidentId()));
            } catch (NumberFormatException e) {
                household.setHeadOfHouseholdResidentId(null);
            }
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
            resident.getResidentId() != null ? resident.getResidentId().toString() : null,
            resident.getHouseholdId() != null ? resident.getHouseholdId().toString() : null,
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
        
        if (residentDto.getResidentId() != null && !residentDto.getResidentId().isEmpty()) {
            try {
                resident.setResidentId(Integer.parseInt(residentDto.getResidentId()));
            } catch (NumberFormatException e) {
                resident.setResidentId(null);
            }
        }
        
        if (residentDto.getHouseholdId() != null && !residentDto.getHouseholdId().isEmpty()) {
            try {
                resident.setHouseholdId(Integer.parseInt(residentDto.getHouseholdId()));
            } catch (NumberFormatException e) {
                resident.setHouseholdId(null);
            }
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
            vehicle.getVehicleId() != null ? vehicle.getVehicleId().toString() : null,
            vehicle.getHouseholdId() != null ? vehicle.getHouseholdId().toString() : null,
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
        
        if (vehicleDto.getVehicleId() != null && !vehicleDto.getVehicleId().isEmpty()) {
            try {
                vehicle.setVehicleId(Integer.parseInt(vehicleDto.getVehicleId()));
            } catch (NumberFormatException e) {
                vehicle.setVehicleId(null);
            }
        }
        
        if (vehicleDto.getHouseholdId() != null && !vehicleDto.getHouseholdId().isEmpty()) {
            try {
                vehicle.setHouseholdId(Integer.parseInt(vehicleDto.getHouseholdId()));
            } catch (NumberFormatException e) {
                vehicle.setHouseholdId(null);
            }
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
     * Ensures proper type conversion: Long->String for IDs, BigDecimal->Double for amount
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
            payment.getPaymentId() != null ? payment.getPaymentId().toString() : null,
            payment.getHouseholdId() != null ? payment.getHouseholdId().toString() : null,
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
        
        if (paymentDto.getPaymentId() != null && !paymentDto.getPaymentId().isEmpty()) {
            try {
                payment.setPaymentId(Integer.parseInt(paymentDto.getPaymentId()));
            } catch (NumberFormatException e) {
                payment.setPaymentId(null);
            }
        }
        
        if (paymentDto.getHouseholdId() != null && !paymentDto.getHouseholdId().isEmpty()) {
            try {
                payment.setHouseholdId(Integer.parseInt(paymentDto.getHouseholdId()));
            } catch (NumberFormatException e) {
                payment.setHouseholdId(null);
            }
        }
        
        payment.setPaymentType(paymentDto.getPaymentType());
        if (paymentDto.getAmount() != null) {
            payment.setAmount(BigDecimal.valueOf(paymentDto.getAmount()));
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
} 