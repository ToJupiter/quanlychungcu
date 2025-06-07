# Spring Boot Backend Project Tree for BlueMoon (20 Files, Compatibility-Centric)

This project tree is designed for a basic, maintainable, and fully compatible Java Spring Boot backend for the BlueMoon Apartment Management System. It ensures all API endpoints, data types, and request/response structures match the Dart frontend and MySQL schema exactly, following good software engineering practices for an undergraduate project.

---

## Project Structure (20 Files)

```
spring_backend/
└── bluemoon/
    ├── BluemoonApplication.java                # Main Spring Boot application
    ├── config/
    │   ├── SecurityConfig.java                 # JWT security configuration
    │   └── JwtUtil.java                        # JWT utility/helper
    ├── controller/
    │   ├── AuthController.java                 # /api/auth endpoints
    │   ├── StaffController.java                # /api/staff endpoints
    │   ├── ApartmentController.java            # /api/management/apartments endpoints
    │   ├── HouseholdController.java            # /api/management/households endpoints
    │   ├── ResidentController.java             # /api/management/residents endpoints
    │   ├── VehicleController.java              # /api/management/vehicles endpoints
    │   └── PaymentController.java              # /api/finance/payments endpoints
    ├── dto/
    │   ├── AuthRequest.java                    # Login/register DTOs
    │   ├── StaffDto.java
    │   ├── ApartmentDto.java
    │   ├── HouseholdDto.java
    │   ├── ResidentDto.java
    │   ├── VehicleDto.java
    │   └── PaymentDto.java
    ├── model/
    │   ├── Staff.java
    │   ├── Apartment.java
    │   ├── Household.java
    │   ├── Resident.java
    │   ├── Vehicle.java
    │   └── Payment.java
    ├── repository/
    │   ├── StaffRepository.java
    │   ├── ApartmentRepository.java
    │   ├── HouseholdRepository.java
    │   ├── ResidentRepository.java
    │   ├── VehicleRepository.java
    │   └── PaymentRepository.java
    ├── service/
    │   ├── AuthService.java
    │   ├── StaffService.java
    │   ├── ApartmentService.java
    │   ├── HouseholdService.java
    │   ├── ResidentService.java
    │   ├── VehicleService.java
    │   └── PaymentService.java
    ├── exception/
    │   ├── GlobalExceptionHandler.java         # @ControllerAdvice for error handling
    │   └── CustomException.java
    └── util/
        └── MapperUtil.java                     # Entity-DTO mapping helpers
```

---

## Design Principles
- **Compatibility First:** All endpoints, field names, and data types must match the Dart frontend and MySQL schema (see datatype_mapping_documentation.md and backend_api_reference.md).
- **Separation of Concerns:** Controllers, services, repositories, DTOs, and models are separated for clarity and maintainability.
- **DTO Usage:** All API input/output uses DTOs to decouple internal models from API contracts and ensure field naming matches frontend.
- **Repository Pattern:** Spring Data JPA repositories for all entities, with custom queries for joins as needed.
- **Service Layer:** All business logic in services, not controllers.
- **Security:** JWT-based authentication, role-based authorization, password hashing with BCrypt.
- **Error Handling:** Centralized with @ControllerAdvice, error format matches frontend expectations.
- **Mapping:** Utility for mapping between entities and DTOs, ensuring correct type conversions (e.g., Long <-> String for IDs, LocalDate <-> ISO 8601, BigDecimal <-> double).
- **Extensibility:** Easy to add new features or extend existing ones.

---

## Implementation Notes
- Use `@RestController` and `@RequestMapping` for all controllers.
- Use `@Entity` for all models, matching MySQL schema exactly (see bluemoon_database.sql).
- Use `@Service` for all business logic.
- Use `@Repository` for all DB access.
- Use `@ControllerAdvice` for error handling.
- Use `@PreAuthorize` or method security for role checks.
- Use `@JsonProperty` in DTOs for snake_case compatibility with frontend.
- All IDs are `Long` in Java, but serialized as `String` in JSON.
- Dates are `LocalDate`/`LocalDateTime`, serialized as ISO 8601.
- All endpoints and data types must match the Dart frontend and Node.js API exactly.

---

> This structure is designed for clarity, maintainability, and undergraduate-level complexity, while ensuring professional design and full compatibility with the existing system.
