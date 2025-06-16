package com.bluemoon.service;

import com.bluemoon.model.Staff;
import com.bluemoon.repository.StaffRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.UUID;

@Service
public class DatabaseInitializationService {

    @Autowired
    private DataSource dataSource;

    @Autowired
    private StaffRepository staffRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @EventListener(ApplicationReadyEvent.class)
    @Transactional
    public void initializeDatabase() {
        try {
            createTablesIfNotExist();
            createDefaultUsers();
        } catch (Exception e) {
            e.printStackTrace();
            // Log error but don't crash the application
        }
    }

    private void createTablesIfNotExist() throws SQLException {
        try (Connection connection = dataSource.getConnection();
             Statement statement = connection.createStatement()) {

            // Create Staff table
            String createStaffTable = """
                CREATE TABLE IF NOT EXISTS Staff (
                    staff_id VARCHAR(50) PRIMARY KEY,
                    full_name VARCHAR(255) NOT NULL,
                    email VARCHAR(255) UNIQUE NOT NULL,
                    phone_number VARCHAR(20),
                    password_hash VARCHAR(255) NOT NULL,
                    status VARCHAR(50),
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    Roles INT NOT NULL COMMENT '0 = Admin, 1 = Accountant'
                )
                """;
            statement.execute(createStaffTable);

            // Create Apartments table
            String createApartmentsTable = """
                CREATE TABLE IF NOT EXISTS Apartments (
                    apartment_id VARCHAR(50) PRIMARY KEY,
                    apartment_number VARCHAR(50) UNIQUE NOT NULL,
                    area FLOAT,
                    status VARCHAR(50)
                )
                """;
            statement.execute(createApartmentsTable);

            // Create Households table
            String createHouseholdsTable = """
                CREATE TABLE IF NOT EXISTS Households (
                    household_id VARCHAR(50) PRIMARY KEY,
                    apartment_id VARCHAR(50),
                    head_of_household_resident_id VARCHAR(50),
                    move_in_date DATE,
                    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id),
                    FOREIGN KEY (head_of_household_resident_id) REFERENCES Residents(resident_id)
                )
                """;

            // Create Residents table first (without foreign key to Households)
            String createResidentsTable = """
                CREATE TABLE IF NOT EXISTS Residents (
                    resident_id VARCHAR(50) PRIMARY KEY,
                    household_id VARCHAR(50),
                    full_name VARCHAR(255) NOT NULL,
                    date_of_birth DATE,
                    cccd_number VARCHAR(20) UNIQUE,
                    role_in_household VARCHAR(50)
                )
                """;
            statement.execute(createResidentsTable);

            // Now create Households table
            statement.execute(createHouseholdsTable);

            // Add foreign key to Residents table
            try {
                String addResidentsForeignKey = """
                    ALTER TABLE Residents 
                    ADD CONSTRAINT FK_Residents_Households 
                    FOREIGN KEY (household_id) REFERENCES Households(household_id)
                    """;
                statement.execute(addResidentsForeignKey);
            } catch (SQLException e) {
                // Foreign key might already exist, ignore
            }

            // Create Vehicles table
            String createVehiclesTable = """
                CREATE TABLE IF NOT EXISTS Vehicles (
                    vehicle_id VARCHAR(50) PRIMARY KEY,
                    household_id VARCHAR(50),
                    plate_number VARCHAR(50) UNIQUE NOT NULL,
                    vehicle_type VARCHAR(50),
                    registration_date DATE,
                    FOREIGN KEY (household_id) REFERENCES Households(household_id)
                )
                """;
            statement.execute(createVehiclesTable);

            // Create Payments table
            String createPaymentsTable = """
                CREATE TABLE IF NOT EXISTS Payments (
                    payment_id VARCHAR(50) PRIMARY KEY,
                    household_id VARCHAR(50),
                    payment_type VARCHAR(100),
                    amount FLOAT,
                    due_date DATE,
                    payment_date DATE,
                    status VARCHAR(50),
                    FOREIGN KEY (household_id) REFERENCES Households(household_id)
                )
                """;
            statement.execute(createPaymentsTable);

            System.out.println("Database tables created successfully!");
        }
    }

    private void createDefaultUsers() {
        try {
            // Check if admin user exists
            if (!staffRepository.existsByEmail("admin@bluemoon.com")) {
                Staff adminStaff = new Staff();
                adminStaff.setStaffId(UUID.randomUUID().toString());
                adminStaff.setFullName("System Administrator");
                adminStaff.setEmail("admin@bluemoon.com");
                adminStaff.setPhoneNumber("0123456789");
                adminStaff.setPasswordHash(passwordEncoder.encode("admin123"));
                adminStaff.setStatus("active");
                adminStaff.setRoles(0); // Admin role
                
                staffRepository.save(adminStaff);
                System.out.println("Default admin user created: admin@bluemoon.com / admin123");
            }

            // Check if accountant user exists
            if (!staffRepository.existsByEmail("accountant@bluemoon.com")) {
                Staff accountantStaff = new Staff();
                accountantStaff.setStaffId(UUID.randomUUID().toString());
                accountantStaff.setFullName("System Accountant");
                accountantStaff.setEmail("accountant@bluemoon.com");
                accountantStaff.setPhoneNumber("0987654321");
                accountantStaff.setPasswordHash(passwordEncoder.encode("accountant123"));
                accountantStaff.setStatus("active");
                accountantStaff.setRoles(1); // Accountant role
                
                staffRepository.save(accountantStaff);
                System.out.println("Default accountant user created: accountant@bluemoon.com / accountant123");
            }
        } catch (Exception e) {
            System.err.println("Error creating default users: " + e.getMessage());
        }
    }
} 