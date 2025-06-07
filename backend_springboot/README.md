# BlueMoon Spring Boot Backend

This is the Spring Boot backend for the BlueMoon Apartment Management System, designed to be fully compatible with the existing Node.js backend and Flutter frontend.

## Project Structure

```
backend_springboot/
├── src/main/java/com/bluemoon/
│   ├── BluemoonApplication.java          # Main Spring Boot application
│   ├── config/
│   │   ├── SecurityConfig.java           # JWT security configuration
│   │   └── JwtUtil.java                  # JWT utility/helper
│   ├── controller/
│   │   ├── AuthController.java           # /api/auth endpoints
│   │   └── TestController.java           # Test endpoints for connectivity
│   ├── dto/
│   │   ├── AuthRequest.java              # Login/register DTOs
│   │   └── StaffDto.java                 # Staff response DTOs
│   ├── model/
│   │   ├── Staff.java
│   │   ├── Apartment.java
│   │   ├── Household.java
│   │   ├── Resident.java
│   │   ├── Vehicle.java
│   │   └── Payment.java
│   ├── repository/
│   │   ├── StaffRepository.java
│   │   ├── ApartmentRepository.java
│   │   ├── HouseholdRepository.java
│   │   ├── ResidentRepository.java
│   │   ├── VehicleRepository.java
│   │   └── PaymentRepository.java
│   ├── service/
│   │   └── AuthService.java              # Authentication business logic
│   ├── exception/
│   │   ├── GlobalExceptionHandler.java   # @ControllerAdvice for error handling
│   │   └── CustomException.java          # Custom exception classes
│   └── util/
│       └── MapperUtil.java               # Entity-DTO mapping helpers
├── src/main/resources/
│   └── application.properties            # Application configuration
└── pom.xml                               # Maven dependencies
```

## Prerequisites

- **Java 17** or higher
- **MySQL 8.0** or higher
- **Maven 3.6** or higher
- **MySQL database** with the BlueMoon schema created (see database setup section)

## Environment Variables

Create a `.env` file in your project root or set the following environment variables:

```properties
# Database Configuration
DB_HOST=localhost
DB_PORT=3306
DB_NAME=bluemoon_apartment_db
DB_USER=your_mysql_username
DB_PASSWORD=your_mysql_password

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-me-in-production

# Server Configuration
PORT=3001
SPRING_PROFILES_ACTIVE=development
```

## Database Setup

1. Create the MySQL database:
```sql
CREATE DATABASE bluemoon_apartment_db;
```

2. Use the database:
```sql
USE bluemoon_apartment_db;
```

3. Run the table creation SQL from `/frontend/bluemoon_database.sql`:
```sql
-- Create all tables as specified in the schema
CREATE TABLE Staff (...);
CREATE TABLE Apartments (...);
-- ... etc
```

## Running the Application

1. **Clone the repository** and navigate to the backend_springboot directory

2. **Set environment variables** or create a `.env` file with the configuration above

3. **Install dependencies**:
```bash
mvn clean install
```

4. **Run the application**:
```bash
mvn spring-boot:run
```

The server will start on port 3001 (or the port specified in your environment variables).

## Testing Database Connection

Once the server is running, test the database connection using these endpoints:

### Health Check
```
GET http://localhost:3001/api/test/health
```
Expected response:
```json
{
  "status": "UP",
  "message": "BlueMoon Spring Boot Backend is running",
  "timestamp": 1234567890
}
```

### Database Connection Test
```
GET http://localhost:3001/api/test/database
```
Expected response:
```json
{
  "status": "SUCCESS",
  "message": "Database connection successful",
  "database": "bluemoon_apartment_db",
  "url": "jdbc:mysql://localhost:3306/bluemoon_apartment_db"
}
```

### Table Access Test
```
GET http://localhost:3001/api/test/tables
```
Expected response:
```json
{
  "status": "SUCCESS",
  "message": "All tables accessible",
  "table_counts": {
    "staff": 0,
    "apartments": 0,
    "households": 0,
    "residents": 0,
    "vehicles": 0,
    "payments": 0
  }
}
```

### Staff Data Test
```
GET http://localhost:3001/api/test/staff-count
```

## API Endpoints

### Authentication Endpoints

#### Register Staff
```
POST /api/auth/staff/register
Content-Type: application/json

{
  "full_name": "John Doe",
  "email": "john.doe@bluemoon.com",
  "phone_number": "0123456789",
  "password": "password123",
  "status": "active"
}
```

#### Login Staff
```
POST /api/auth/staff/login
Content-Type: application/json

{
  "email": "john.doe@bluemoon.com",
  "password": "password123"
}
```

#### Change Password
```
POST /api/auth/staff/change-password
Content-Type: application/json
Authorization: Bearer <jwt_token>

{
  "oldPassword": "password123",
  "newPassword": "newpassword123"
}
```

## Data Type Compatibility

This Spring Boot backend ensures full compatibility with the Flutter frontend:

- **IDs**: MySQL `BIGINT` → Java `Long` → JSON `String` (for frontend compatibility)
- **Dates**: MySQL `DATE`/`TIMESTAMP` → Java `LocalDate`/`LocalDateTime` → JSON ISO 8601 strings
- **Decimals**: MySQL `DECIMAL` → Java `BigDecimal` → JSON numbers (parsed as `double` in Flutter)
- **Field Naming**: Uses `@JsonProperty` annotations to match snake_case expected by frontend

## Error Handling

All errors follow the same format as the Node.js backend:

```json
{
  "status": "error",
  "statusCode": 400,
  "message": "Error description",
  "timestamp": "2024-01-01T12:00:00"
}
```

## Next Steps

1. **Test Database Connection**: Run the application and verify all test endpoints work
2. **Add Sample Data**: Insert some test data to verify CRUD operations
3. **Implement Additional Controllers**: Add controllers for apartments, households, etc.
4. **Add JWT Authentication Filter**: Implement proper JWT middleware for protected routes
5. **Add Integration Tests**: Create comprehensive tests for all endpoints

## Troubleshooting

### Database Connection Issues
- Verify MySQL is running and accessible
- Check database credentials in environment variables
- Ensure the database `bluemoon_apartment_db` exists
- Check firewall settings and MySQL user permissions

### Application Startup Issues
- Verify Java 17+ is installed
- Check Maven dependencies with `mvn dependency:tree`
- Review application logs for specific error messages
- Ensure no other service is running on port 3001

### API Compatibility Issues
- Compare response formats with the Node.js backend
- Check field naming conventions (snake_case vs camelCase)
- Verify data type conversions are working correctly 