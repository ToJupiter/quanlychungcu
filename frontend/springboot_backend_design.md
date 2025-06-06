# Java Spring Boot Backend Design for BlueMoon (API-Compatible, MySQL-Compatible, Dart-Compatible)

This document provides a detailed design for a Java Spring Boot backend (≤10 files) that is fully compatible with the existing MySQL schema and Dart frontend. The API structure, data types, and endpoints are preserved for seamless migration and integration.

---

## 1. Project Structure (≤10 Files)

- `BluemoonApplication.java` (Spring Boot main class)
- `config/SecurityConfig.java` (JWT security config)
- `model/` (Entities)
  - `Staff.java`
  - `Apartment.java`
  - `Household.java`
  - `Resident.java`
  - `Vehicle.java`
  - `Payment.java`
- `controller/ApiController.java` (All REST endpoints)
- `repository/` (Spring Data JPA interfaces)
  - `StaffRepository.java`, ... (or use inline in controller for brevity)
- `service/ApiService.java` (Business logic, optional for brevity)
- `util/JwtUtil.java` (JWT helper, can be merged with config)

---

## 2. Entity Design (model/*)
- Use JPA annotations to match MySQL schema exactly.
- All IDs: `@Id @GeneratedValue(strategy = GenerationType.IDENTITY) Long id;` (convert to String in JSON response)
- Dates: `LocalDate` or `LocalDateTime` (Jackson auto-converts to ISO 8601)
- Decimal: `BigDecimal` (Jackson serializes as number)
- Nullability: Use boxed types (`String`, `LocalDate`, etc.)
- Enum-like fields: Use `String` (for status, role, etc.)

---

## 3. API Controller Design (controller/ApiController.java)
- Use `@RestController`
- Map all endpoints to match Node.js API (see backend_api_reference.md)
- Use `@RequestMapping` for grouping (e.g., `/api/staff`, `/api/management`, `/api/finance`)
- Use DTOs for request/response if needed, or expose entities directly (with @JsonProperty for field names)
- Always return IDs as String in JSON (use Jackson config or getter)
- Use `@RequestParam` for query params, `@PathVariable` for path params
- Use `@RequestBody` for POST/PUT/PATCH

---

## 4. Security (config/SecurityConfig.java, util/JwtUtil.java)
- Use Spring Security with JWT filter
- Passwords: BCryptPasswordEncoder
- Role-based access: `@PreAuthorize` or method-level security
- Expose `/api/auth/*` as public, others as protected

---

## 5. Repository Layer (repository/*)
- Use Spring Data JPA interfaces for each entity
- Custom queries for joins (e.g., household details) using `@Query`
- Use projections or DTOs for nested/complex responses

---

## 6. Data Type Mapping
- MySQL INT → Java Long (serialize as String)
- MySQL VARCHAR → Java String
- MySQL DATE/TIMESTAMP → Java LocalDate/LocalDateTime
- MySQL DECIMAL → Java BigDecimal
- All nullable fields: use boxed types
- All JSON fields: use camelCase or snake_case as needed (Jackson config)

---

## 7. API Compatibility
- All endpoints, request/response bodies, and query params must match the Node.js API (see backend_api_reference.md)
- Dates must be ISO 8601 strings
- IDs must be serialized as String
- Nullability and optional fields must match Dart model expectations
- Nested objects (e.g., residents, vehicles in household details) must be returned as arrays

---

## 8. Example: Staff Entity and Endpoint

**Staff.java**
```java
@Entity
@Table(name = "Staff")
public class Staff {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long staffId;
    private String fullName;
    private String email;
    private String phoneNumber;
    private String passwordHash;
    private String status;
    private LocalDateTime createdAt;
    // Getters/setters, @JsonProperty for field names
}
```

**ApiController.java (partial)**
```java
@RestController
@RequestMapping("/api/staff")
public class ApiController {
    @Autowired StaffRepository staffRepo;
    // ...
    @GetMapping
    public List<StaffDto> getAllStaff(@RequestParam Optional<String> status, @RequestParam Optional<String> search) {
        // Query staffRepo, map to DTO, return
    }
    @PostMapping
    public StaffDto createStaff(@RequestBody StaffCreateDto req) {
        // Validate, hash password, save, return DTO
    }
    // ...
}
```

---

## 9. Error Handling
- Use `@ControllerAdvice` for global error handling
- Return errors in `{ status: 'error', statusCode, message }` format
- Validate all required fields, return 400/422 on error

---

## 10. Testing & Extensibility
- Use JUnit for unit/integration tests
- Keep code modular for future extension (e.g., add file upload, reporting)

---

## 11. File List (≤10 files, can merge for brevity)
1. BluemoonApplication.java
2. config/SecurityConfig.java
3. model/Staff.java
4. model/Apartment.java
5. model/Household.java
6. model/Resident.java
7. model/Vehicle.java
8. model/Payment.java
9. controller/ApiController.java
10. repository/StaffRepository.java (and others, or inline)

---

> This design ensures a minimal, maintainable, and fully compatible Java Spring Boot backend for BlueMoon, ready for direct implementation.
