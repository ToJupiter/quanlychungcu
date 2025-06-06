# Data Type Mapping and Challenges: Flutter Frontend ↔ Node.js Backend ↔ MySQL

This documentation provides a deep dive into the data type challenges and mappings for every major functionality in the BlueMoon Apartment Management System. It links each Dart model field to the backend API and MySQL schema, highlighting potential pitfalls and best practices.

---

## 1. Staff Management

### Dart Model (`Staff`)
| Dart Field      | Type         | Backend JSON Key   | Backend Type (JS) | MySQL Column         | MySQL Type         | Notes/Challenges |
|----------------|--------------|--------------------|-------------------|----------------------|--------------------|------------------|
| id             | String       | staff_id           | String/Number     | staff_id             | INT (AUTO_INCREMENT)| Always sent as string in frontend; backend converts to string for JSON. |
| fullName       | String       | full_name          | String            | full_name            | VARCHAR(255)       |                  |
| email          | String       | email              | String            | email                | VARCHAR(255)       | Unique.          |
| phoneNumber    | String?      | phone_number       | String/Null       | phone_number         | VARCHAR(20)        | Nullable.        |
| status         | String       | status             | String            | status               | VARCHAR(50)        | Enum-like.       |
| createdAt      | DateTime?    | created_at         | String/Date       | created_at           | TIMESTAMP          | Sent as ISO string; parsed in Dart. |

**Challenges:**
- MySQL returns `created_at` as a string (e.g., '2024-06-04T12:34:56.000Z'), which must be parsed to `DateTime` in Dart.
- `id` is an integer in MySQL but always handled as a string in Dart for consistency.
- Nullability must be handled for `phoneNumber` and `createdAt`.

---

## 2. Apartment Management

### Dart Model (`Apartment`)
| Dart Field      | Type         | Backend JSON Key   | Backend Type (JS) | MySQL Column         | MySQL Type         | Notes/Challenges |
|----------------|--------------|--------------------|-------------------|----------------------|--------------------|------------------|
| id             | String       | apartment_id       | String/Number     | apartment_id         | INT (AUTO_INCREMENT)|                  |
| apartmentNumber| String       | apartment_number   | String            | apartment_number     | VARCHAR(50)        | Unique.          |
| area           | double       | area               | Number            | area                 | DECIMAL(10,2)      | Must parse as double in Dart. |
| status         | String       | status             | String            | status               | VARCHAR(50)        |                  |

**Challenges:**
- MySQL `DECIMAL` is returned as string or number; Dart must parse to `double`.
- `id` is always stringified for frontend.

---

## 3. Household Management

### Dart Model (`Household`)
| Dart Field         | Type         | Backend JSON Key         | Backend Type (JS) | MySQL Column/Join         | MySQL Type         | Notes/Challenges |
|-------------------|--------------|-------------------------|-------------------|--------------------------|--------------------|------------------|
| id                | String       | household_id            | String/Number     | household_id             | INT (AUTO_INCREMENT)|                  |
| apartmentId       | String       | apartment_id            | String/Number     | apartment_id             | INT                |                  |
| apartmentNumber   | String       | apartment_number        | String            | apartment_number (join)  | VARCHAR(50)        |                  |
| apartmentArea     | double       | apartment_area          | Number            | area (join)              | DECIMAL(10,2)      |                  |
| apartmentStatus   | String       | apartment_status        | String            | status (join)            | VARCHAR(50)        |                  |
| headResidentId    | String       | head_resident_id        | String/Number     | head_of_household_resident_id | INT           |                  |
| headResidentName  | String       | head_full_name          | String            | full_name (join)         | VARCHAR(255)       |                  |
| headResidentDob   | DateTime?    | head_dob                | String/Date       | date_of_birth (join)     | DATE               |                  |
| headResidentCccd  | String?      | head_cccd               | String            | cccd_number (join)       | VARCHAR(20)        |                  |
| moveInDate        | DateTime     | move_in_date            | String/Date       | move_in_date             | DATE               |                  |
| residents         | List<Resident>| residents               | Array             | -                        | -                  | Nested JSON.     |
| vehicles          | List<Vehicle>| vehicles                | Array             | -                        | -                  | Nested JSON.     |

**Challenges:**
- Many fields are joined from other tables; backend must ensure correct joins and type conversions.
- Dates are always sent as ISO strings; Dart parses to `DateTime`.
- Nested lists (`residents`, `vehicles`) must be handled as arrays of objects in JSON.

---

## 4. Resident Management

### Dart Model (`Resident`)
| Dart Field      | Type         | Backend JSON Key   | Backend Type (JS) | MySQL Column         | MySQL Type         | Notes/Challenges |
|----------------|--------------|--------------------|-------------------|----------------------|--------------------|------------------|
| id             | String       | resident_id        | String/Number     | resident_id          | INT (AUTO_INCREMENT)|                  |
| householdId    | String       | household_id       | String/Number     | household_id         | INT                |                  |
| fullName       | String       | full_name          | String            | full_name            | VARCHAR(255)       |                  |
| dateOfBirth    | DateTime?    | date_of_birth      | String/Date       | date_of_birth        | DATE               |                  |
| cccdNumber     | String?      | cccd_number        | String            | cccd_number          | VARCHAR(20)        |                  |
| roleInHousehold| String?      | role_in_household  | String            | role_in_household    | VARCHAR(50)        |                  |

**Challenges:**
- `dateOfBirth` is nullable and must be parsed from string.
- `id` and `householdId` are always stringified.

---

## 5. Vehicle Management

### Dart Model (`Vehicle`)
| Dart Field      | Type         | Backend JSON Key   | Backend Type (JS) | MySQL Column         | MySQL Type         | Notes/Challenges |
|----------------|--------------|--------------------|-------------------|----------------------|--------------------|------------------|
| id             | String       | vehicle_id         | String/Number     | vehicle_id           | INT (AUTO_INCREMENT)|                  |
| householdId    | String       | household_id       | String/Number     | household_id         | INT                |                  |
| plateNumber    | String       | plate_number       | String            | plate_number         | VARCHAR(50)        | Unique.          |
| vehicleType    | String?      | vehicle_type       | String            | vehicle_type         | VARCHAR(50)        | Nullable.        |
| registrationDate| DateTime?   | registration_date  | String/Date       | registration_date    | DATE               | Nullable.        |

**Challenges:**
- `registrationDate` is nullable and must be parsed from string.

---

## 6. Payment Management

### Dart Model (`Payment`)
| Dart Field      | Type         | Backend JSON Key   | Backend Type (JS) | MySQL Column         | MySQL Type         | Notes/Challenges |
|----------------|--------------|--------------------|-------------------|----------------------|--------------------|------------------|
| id             | String       | payment_id         | String/Number     | payment_id           | INT (AUTO_INCREMENT)|                  |
| householdId    | String       | household_id       | String/Number     | household_id         | INT                |                  |
| apartmentId    | String?      | apartment_id       | String/Number     | apartment_id (join)  | INT                |                  |
| apartmentNumber| String?      | apartment_number   | String            | apartment_number (join)| VARCHAR(50)      |                  |
| paymentType    | String       | payment_type       | String            | payment_type         | VARCHAR(100)       |                  |
| amount         | double       | amount             | Number            | amount               | DECIMAL(10,2)      | Must parse as double in Dart. |
| paymentDate    | DateTime?    | payment_date       | String/Date       | payment_date         | DATE               | Nullable.        |
| status         | String       | status             | String            | status               | VARCHAR(50)        |                  |
| notes          | String?      | notes              | String            | notes (not in schema)| -                  | May be missing in DB.         |
| dueDate        | DateTime?    | due_date           | String/Date       | due_date             | DATE               | Nullable.        |

**Challenges:**
- `amount` is a `DECIMAL` in MySQL, which may be returned as string or number; Dart must parse to `double`.
- Dates are always sent as ISO strings; Dart parses to `DateTime`.
- `notes` field may not exist in DB, but is present in backend response.

---

## 7. General Data Type Challenges
- **ID Handling:** All IDs are integers in MySQL, but are always stringified in backend responses and Dart models for consistency and to avoid type issues in Flutter.
- **Date Handling:** All dates/timestamps are sent as ISO strings from backend; Dart parses them to `DateTime?`. Nullability must be handled.
- **Decimal/Double:** MySQL `DECIMAL` fields may be returned as string or number; always parse to `double` in Dart.
- **Nullability:** Many fields are nullable in both backend and frontend; always check for null before parsing or displaying.
- **Enum-like Strings:** Fields like `status`, `role_in_household`, etc., are strings but should be treated as enums in Dart for type safety.
- **Backend Consistency:** Backend must always return consistent types (e.g., never send an integer for a field that is expected as a string in Dart).

---

## 8. Recommendations
- Always stringify IDs in backend responses.
- Always send dates as ISO 8601 strings.
- Always parse `DECIMAL`/`FLOAT` as `double` in Dart.
- Document all nullable fields and handle them gracefully in both backend and frontend.
- Consider using enums in Dart for fields with limited values (e.g., status).
- Keep backend and frontend models in sync; update both when schema changes.

---

> This documentation should be updated whenever the database schema, backend API, or Dart models change.
