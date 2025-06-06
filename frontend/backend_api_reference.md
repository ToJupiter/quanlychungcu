# BlueMoon Backend API Reference & Architecture Documentation

This document provides a comprehensive reference for every feature of the BlueMoon Node.js backend, including API endpoints, parameters, data types, request/response structures, and how the backend interacts with the MySQL database. It is intended for developers integrating the backend with the Flutter frontend or for future migration/maintenance.

---

## 1. Overview
- **Framework:** Node.js with Express.js
- **Database:** MySQL (using `mysql2/promise`)
- **Structure:**
  - `controllers/`: Business logic for each domain (staff, management, finance, auth)
  - `routes/`: API route definitions
  - `middlewares.js`: JWT authentication, role-based authorization, error handling
  - `database.js`: MySQL connection pool
  - `config.js`: Configuration (DB, JWT secret, etc.)

---

## 2. Authentication & Authorization
- **JWT-based authentication**
- **Role-based authorization** (middleware, e.g., `authorizeRole(['Admin_BQT'])`)

### Endpoints
#### POST `/api/auth/staff/register`
- **Description:** Register a new staff member
- **Body:**
  ```json
  {
    "full_name": "string (required)",
    "email": "string (required)",
    "phone_number": "string (optional)",
    "password": "string (required)",
    "status": "string (optional, default: 'active')"
  }
  ```
- **Returns:**
  ```json
  {
    "message": "Staff registered successfully",
    "staffId": "number (new staff id)"
  }
  ```
- **Notes:** Only for admin/BQT in production

#### POST `/api/auth/staff/login`
- **Description:** Staff login
- **Body:**
  ```json
  {
    "email": "string (required)",
    "password": "string (required)"
  }
  ```
- **Returns:**
  ```json
  {
    "token": "JWT string",
    "staff": {
      "staff_id": "string",
      "full_name": "string",
      "email": "string",
      "phone_number": "string|null",
      "status": "string",
      "created_at": "string (ISO date)"
    }
  }
  ```

#### POST `/api/auth/staff/change-password`
- **Description:** Change password (authenticated)
- **Body:**
  ```json
  {
    "oldPassword": "string (required)",
    "newPassword": "string (required)"
  }
  ```
- **Returns:**
  ```json
  {
    "message": "Password changed successfully"
  }
  ```

---

## 3. Staff Management

### Endpoints
#### GET `/api/staff`
- **Description:** Get all staff (with optional filtering)
- **Query:** `status` (string), `search` (string)
- **Returns:**
  ```json
  [
    {
      "staff_id": "string",
      "full_name": "string",
      "email": "string",
      "phone_number": "string|null",
      "status": "string",
      "created_at": "string (ISO date)"
    },
    ...
  ]
  ```

#### GET `/api/staff/:id`
- **Description:** Get staff by ID
- **Returns:**
  ```json
  {
    "staff_id": "string",
    "full_name": "string",
    "email": "string",
    "phone_number": "string|null",
    "status": "string",
    "created_at": "string (ISO date)"
  }
  ```

#### POST `/api/staff`
- **Description:** Create new staff
- **Body:**
  ```json
  {
    "full_name": "string (required)",
    "email": "string (required)",
    "phone_number": "string (optional)",
    "password": "string (required)",
    "status": "string (optional, default: 'active')"
  }
  ```
- **Returns:**
  ```json
  {
    "message": "Staff created successfully",
    "staffId": "number (new staff id)"
  }
  ```

#### PUT `/api/staff/:id`
- **Description:** Update staff
- **Body:**
  ```json
  {
    "full_name": "string (required)",
    "email": "string (required)",
    "phone_number": "string (optional)",
    "status": "string (required)"
  }
  ```
- **Returns:**
  ```json
  {
    "message": "Staff updated successfully"
  }
  ```

#### PATCH `/api/staff/:id/status`
- **Description:** Update staff status (activate/deactivate)
- **Body:**
  ```json
  {
    "status": "string (required, e.g. 'active' or 'inactive')"
  }
  ```
- **Returns:**
  ```json
  {
    "message": "Staff status updated successfully"
  }
  ```

#### PATCH `/api/staff/:id/reset-password`
- **Description:** Reset staff password (admin)
- **Body:**
  ```json
  {
    "password": "string (required)"
  }
  ```
- **Returns:**
  ```json
  {
    "message": "Password reset successfully"
  }
  ```

#### DELETE `/api/staff/:id`
- **Description:** Delete (deactivate) staff
- **Returns:**
  ```json
  {
    "message": "Staff deleted successfully"
  }
  ```

---

## 4. Apartment Management

### Endpoints
#### POST `/api/management/apartments`
- **Description:** Create apartment
- **Body:**
  ```json
  {
    "apartment_number": "string (required)",
    "area": "number (required)",
    "status": "string (required)"
  }
  ```
- **Returns:**
  ```json
  {
    "apartment_id": "string",
    "apartment_number": "string",
    "area": "number",
    "status": "string"
  }
  ```

#### GET `/api/management/apartments`
- **Description:** Get all apartments
- **Returns:**
  ```json
  [
    {
      "apartment_id": "string",
      "apartment_number": "string",
      "area": "number",
      "status": "string"
    },
    ...
  ]
  ```

#### GET `/api/management/apartments/:id`
- **Description:** Get apartment by ID
- **Returns:**
  ```json
  {
    "apartment_id": "string",
    "apartment_number": "string",
    "area": "number",
    "status": "string"
  }
  ```

#### PUT `/api/management/apartments/:id`
- **Description:** Update apartment
- **Body:**
  ```json
  {
    "apartment_number": "string (required)",
    "area": "number (required)",
    "status": "string (required)"
  }
  ```
- **Returns:**
  ```json
  {
    "message": "Apartment updated successfully"
  }
  ```

#### DELETE `/api/management/apartments/:id`
- **Description:** Delete apartment
- **Returns:**
  ```json
  {
    "message": "Apartment deleted successfully"
  }
  ```

---

## 5. Household Management

### Endpoints
#### POST `/api/management/households`
- **Description:** Create household (with head resident)
- **Body:**
  ```json
  {
    "apartment_id": "string (required)",
    "head_of_household_resident_id": "string (optional, can be null)",
    "move_in_date": "string (required, ISO date)",
    // Optionally, head resident info if creating together
    "head_resident": {
      "full_name": "string",
      "date_of_birth": "string (ISO date)",
      "cccd_number": "string",
      "role_in_household": "string"
    }
  }
  ```
- **Returns:**
  ```json
  {
    "household_id": "string",
    "apartment_id": "string",
    "move_in_date": "string (ISO date)",
    ...
  }
  ```

#### GET `/api/management/households`
- **Description:** Get all households
- **Returns:**
  ```json
  [
    {
      "household_id": "string",
      "apartment_id": "string",
      "move_in_date": "string (ISO date)",
      ...
    },
    ...
  ]
  ```

#### GET `/api/management/households/:id/details`
- **Description:** Get household details (with residents, vehicles)
- **Returns:**
  ```json
  {
    "household_id": "string",
    "apartment_id": "string",
    "apartment_number": "string",
    "apartment_area": "number",
    "apartment_status": "string",
    "head_resident_id": "string",
    "head_full_name": "string",
    "head_dob": "string (ISO date)",
    "head_cccd": "string",
    "move_in_date": "string (ISO date)",
    "residents": [ ... ],
    "vehicles": [ ... ]
  }
  ```

---

## 6. Resident Management

### Endpoints
#### POST `/api/management/households/:household_id/residents`
- **Description:** Add resident to household
- **Body:**
  ```json
  {
    "full_name": "string (required)",
    "date_of_birth": "string (ISO date, required)",
    "cccd_number": "string (optional)",
    "role_in_household": "string (optional)"
  }
  ```
- **Returns:**
  ```json
  {
    "resident_id": "string",
    "household_id": "string",
    "full_name": "string",
    "date_of_birth": "string (ISO date)",
    "cccd_number": "string",
    "role_in_household": "string"
  }
  ```

#### PUT `/api/management/residents/:resident_id`
- **Description:** Update resident
- **Body:**
  ```json
  {
    "full_name": "string (required)",
    "date_of_birth": "string (ISO date, required)",
    "cccd_number": "string (optional)",
    "role_in_household": "string (optional)"
  }
  ```
- **Returns:**
  ```json
  {
    "message": "Resident updated successfully"
  }
  ```

#### DELETE `/api/management/residents/:resident_id`
- **Description:** Delete resident
- **Returns:**
  ```json
  {
    "message": "Resident deleted successfully"
  }
  ```

#### GET `/api/management/residents/count`
- **Description:** Get total number of residents
- **Returns:**
  ```json
  {
    "count": "number"
  }
  ```

---

## 7. Vehicle Management

### Endpoints
#### POST `/api/management/households/:household_id/vehicles`
- **Description:** Add/register vehicle to household
- **Body:**
  ```json
  {
    "plate_number": "string (required)",
    "vehicle_type": "string (required)",
    "registration_date": "string (ISO date, required)"
  }
  ```
- **Returns:**
  ```json
  {
    "vehicle_id": "string",
    "household_id": "string",
    "plate_number": "string",
    "vehicle_type": "string",
    "registration_date": "string (ISO date)"
  }
  ```

#### GET `/api/management/households/:household_id/vehicles`
- **Description:** Get vehicles for household
- **Returns:**
  ```json
  [
    {
      "vehicle_id": "string",
      "household_id": "string",
      "plate_number": "string",
      "vehicle_type": "string",
      "registration_date": "string (ISO date)"
    },
    ...
  ]
  ```

---

## 8. Payment Management

### Endpoints
#### POST `/api/finance/payments`
- **Description:** Create payment record
- **Body:**
  ```json
  {
    "household_id": "string (required)",
    "payment_type": "string (required)",
    "amount": "number (required)",
    "due_date": "string (ISO date, required)",
    "payment_date": "string (ISO date, optional)",
    "status": "string (optional, default: 'Unpaid')"
  }
  ```
- **Returns:**
  ```json
  {
    "payment_id": "string",
    "household_id": "string",
    "apartment_id": "string",
    "apartment_number": "string",
    "payment_type": "string",
    "amount": "number",
    "due_date": "string (ISO date)",
    "payment_date": "string (ISO date|null)",
    "status": "string",
    "notes": "string|null"
  }
  ```

#### GET `/api/finance/households/:household_id/payments`
- **Description:** Get all payments for a household
- **Returns:**
  ```json
  [
    {
      "payment_id": "string",
      "household_id": "string",
      "apartment_id": "string",
      "apartment_number": "string",
      "payment_type": "string",
      "amount": "number",
      "due_date": "string (ISO date)",
      "payment_date": "string (ISO date|null)",
      "status": "string",
      "notes": "string|null"
    },
    ...
  ]
  ```

#### GET `/api/finance/payments`
- **Description:** Get all payments (filterable)
- **Query:** `status` (string), `date range` (string), etc.
- **Returns:**
  ```json
  [
    {
      "payment_id": "string",
      "household_id": "string",
      "apartment_id": "string",
      "apartment_number": "string",
      "payment_type": "string",
      "amount": "number",
      "due_date": "string (ISO date)",
      "payment_date": "string (ISO date|null)",
      "status": "string",
      "notes": "string|null"
    },
    ...
  ]
  ```

#### GET `/api/finance/payments/:payment_id`
- **Description:** Get payment by ID
- **Returns:**
  ```json
  {
    "payment_id": "string",
    "household_id": "string",
    "apartment_id": "string",
    "apartment_number": "string",
    "payment_type": "string",
    "amount": "number",
    "due_date": "string (ISO date)",
    "payment_date": "string (ISO date|null)",
    "status": "string",
    "notes": "string|null"
  }
  ```

#### PATCH `/api/finance/payments/:payment_id/status`
- **Description:** Update payment status
- **Body:**
  ```json
  {
    "status": "string (required)",
    "payment_date": "string (ISO date, optional)"
  }
  ```
- **Returns:**
  ```json
  {
    "message": "Payment status updated successfully"
  }
  ```

#### DELETE `/api/finance/payments/:payment_id`
- **Description:** Delete payment
- **Returns:**
  ```json
  {
    "message": "Payment deleted successfully"
  }
  ```

---

## 9. Reporting

### Endpoints
#### GET `/api/finance/reports/financial-summary`
- **Description:** Generate financial summary report
- **Returns:**
  ```json
  {
    // Example fields (actual may vary)
    "total_payments": "number",
    "total_paid": "number",
    "total_unpaid": "number",
    ...
  }
  ```

---

## 10. Data Types & Structure
- **IDs:** Always integers in MySQL, but stringified in API responses for frontend compatibility.
- **Dates:** Stored as `DATE` or `TIMESTAMP` in MySQL, sent as ISO 8601 strings in API.
- **Decimals:** MySQL `DECIMAL` fields sent as numbers or strings; frontend parses as `double`.
- **Nullability:** Nullable fields in DB are sent as `null` or omitted in JSON.
- **Nested Data:** Some endpoints return nested arrays (e.g., residents, vehicles in household details).

---

## 11. Backend-Database Interaction
- **Uses MySQL connection pool** (`mysql2/promise`)
- **Raw SQL queries** for all CRUD operations
- **Joins** used for composite/nested data (e.g., household details)
- **Transactions** not always used; consider for multi-step operations
- **Error handling:** All errors passed to global error handler middleware

---

## 12. Error Handling
- **Consistent error format:** `{ status: 'error', statusCode, message }`
- **Validation:** All endpoints validate required fields and types; missing/invalid data returns 400/422
- **Authentication errors:** 401/403 with clear messages

---

## 13. Security
- **JWT required** for all protected endpoints
- **Role checks** for sensitive actions (e.g., staff registration)
- **Password hashing:** Uses bcryptjs

---

## 14. Usage Example (API Call)

```http
POST /api/finance/payments
Content-Type: application/json
Authorization: Bearer <token>

{
  "household_id": "1",
  "payment_type": "Service Fee",
  "amount": 500000,
  "due_date": "2025-06-30",
  "status": "Unpaid"
}
```

**Response:**
```json
{
  "payment_id": "10",
  "household_id": "1",
  "payment_type": "Service Fee",
  "amount": 500000,
  "due_date": "2025-06-30",
  "status": "Unpaid",
  ...
}
```

---

> This documentation should be updated as the backend evolves or if the database schema/API changes.
