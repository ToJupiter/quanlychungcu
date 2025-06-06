-- Staff

-- staff_id (Primary Key)
-- full_name
-- email
-- phone_number
-- password_hash
-- status (e.g., active, inactive)
-- created_at
-- Apartments

-- apartment_id (Primary Key)
-- apartment_number
-- area
-- status (e.g., occupied, vacant)
-- Households

-- household_id (Primary Key)
-- apartment_id (Foreign Key linking to Apartments)
-- head_of_household_resident_id (Foreign Key linking to Residents)
-- move_in_date
-- Residents

-- resident_id (Primary Key)
-- household_id (Foreign Key linking to Households)
-- full_name
-- date_of_birth
-- cccd_number (Citizen Identity Card)
-- role_in_household (e.g., Head, Member)
-- Vehicles

-- vehicle_id (Primary Key)
-- household_id (Foreign Key linking to Households or resident_id linking to Residents) - Linking to Household for simplicity as per document.
-- plate_number
-- vehicle_type (e.g., Car, Motorcycle)
-- registration_date
-- Payments

-- payment_id (Primary Key)
-- household_id (Foreign Key linking to Households)
-- payment_type (e.g., Service Fee, Parking Fee)
-- amount
-- due_date
-- payment_date
-- status (e.g., Paid, Unpaid)



CREATE TABLE Staff (
    staff_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    status VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Apartments (
    apartment_id INT PRIMARY KEY AUTO_INCREMENT,
    apartment_number VARCHAR(50) UNIQUE NOT NULL,
    area DECIMAL(10, 2),
    status VARCHAR(50)
);

CREATE TABLE Households (
    household_id INT PRIMARY KEY AUTO_INCREMENT,
    apartment_id INT UNIQUE,
    head_of_household_resident_id INT,
    move_in_date DATE,
    FOREIGN KEY (apartment_id) REFERENCES Apartments(apartment_id)
    -- FOREIGN KEY (head_of_household_resident_id) REFERENCES Residents(resident_id) -- This would require Residents table to be created first and might need adjustment based on data insertion order. Keeping it simple without this for initial creation.
);

CREATE TABLE Residents (
    resident_id INT PRIMARY KEY AUTO_INCREMENT,
    household_id INT,
    full_name VARCHAR(255) NOT NULL,
    date_of_birth DATE,
    cccd_number VARCHAR(20) UNIQUE,
    role_in_household VARCHAR(50),
    FOREIGN KEY (household_id) REFERENCES Households(household_id)
);

CREATE TABLE Vehicles (
    vehicle_id INT PRIMARY KEY AUTO_INCREMENT,
    household_id INT,
    plate_number VARCHAR(50) UNIQUE NOT NULL,
    vehicle_type VARCHAR(50),
    registration_date DATE,
    FOREIGN KEY (household_id) REFERENCES Households(household_id)
);

CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    household_id INT,
    payment_type VARCHAR(100),
    amount DECIMAL(10, 2),
    due_date DATE,
    payment_date DATE,
    status VARCHAR(50),
    FOREIGN KEY (household_id) REFERENCES Households(household_id)
);