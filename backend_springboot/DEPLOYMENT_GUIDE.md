# BlueMoon Spring Boot Backend - Deployment Guide

## 🎉 Project Completion Status: **READY FOR PRODUCTION**

The Spring Boot backend has been successfully completed and is fully compatible with the Node.js backend API and Flutter frontend.

## Quick Start

### Prerequisites
- Java 17 or higher
- MySQL 8.0 or higher
- Maven 3.6 or higher

### 1. Database Setup
Create the MySQL database using the schema from `frontend/bluemoon_database.sql`:

```sql
CREATE DATABASE apartment_management_db;
USE apartment_management_db;

-- Run all CREATE TABLE statements from bluemoon_database.sql
```

### 2. Configuration
Update `src/main/resources/application.properties`:

```properties
# Database Configuration
spring.datasource.url=jdbc:mysql://localhost:3306/apartment_management_db
spring.datasource.username=your_mysql_username
spring.datasource.password=your_mysql_password

# JWT Configuration
app.jwt.secret=your_very_secret_key_for_jwt_change_in_production
app.jwt.expiration=86400000

# Server Configuration
server.port=8080
```

### 3. Build and Run

#### Option A: Development Mode
```bash
mvn spring-boot:run
```

#### Option B: Production JAR
```bash
mvn clean package
java -jar target/bluemoon-backend-0.0.1-SNAPSHOT.jar
```

### 4. Verify Installation
The API will be available at: `http://localhost:8080`

Test endpoints:
- `GET /api/test/health` - Health check
- `POST /api/auth/staff/register` - Register first admin user

## API Endpoints

### Authentication (`/api/auth`)
- `POST /staff/register` - Register staff
- `POST /staff/login` - Staff login  
- `POST /staff/change-password` - Change password

### Staff Management (`/api/staff`)
- `GET /` - Get all staff
- `GET /stats` - Get staff statistics
- `GET /{id}` - Get staff by ID
- `POST /` - Create staff
- `PUT /{id}` - Update staff
- `PATCH /{id}/status` - Update staff status
- `PATCH /{id}/reset-password` - Reset password
- `DELETE /{id}` - Delete staff

### Apartment Management (`/api/management/apartments`)
- `POST /` - Create apartment
- `GET /` - Get all apartments
- `GET /{id}` - Get apartment by ID
- `PUT /{id}` - Update apartment
- `DELETE /{id}` - Delete apartment

### Household Management (`/api/management/households`)
- `POST /` - Create household
- `GET /` - Get all households
- `GET /{id}/details` - Get household details

### Resident Management (`/api/management`)
- `POST /households/{household_id}/residents` - Add resident
- `PUT /residents/{resident_id}` - Update resident
- `DELETE /residents/{resident_id}` - Delete resident
- `GET /residents/count` - Get resident count

### Vehicle Management (`/api/management`)
- `POST /households/{household_id}/vehicles` - Add vehicle
- `GET /households/{household_id}/vehicles` - Get vehicles
- `PUT /vehicles/{vehicle_id}` - Update vehicle
- `DELETE /vehicles/{vehicle_id}` - Delete vehicle

### Payment Management (`/api/finance`)
- `POST /payments` - Create payment
- `GET /households/{household_id}/payments` - Get payments by household
- `GET /payments` - Get all payments
- `GET /payments/{payment_id}` - Get payment by ID
- `PATCH /payments/{payment_id}/status` - Update payment status
- `PUT /payments/{payment_id}` - Update payment
- `DELETE /payments/{payment_id}` - Delete payment
- `GET /reports/financial-summary` - Financial summary

## Frontend Integration

### Flutter Configuration
Update your Flutter app's API base URL to point to the Spring Boot backend:

```dart
// In your Flutter app
const String baseUrl = 'http://localhost:8080/api';
```

### Data Format Compatibility
All API responses match the Node.js backend format exactly:
- IDs are returned as strings
- Dates are in ISO format (`yyyy-MM-dd`)
- Amounts are returned as doubles
- Field names use snake_case

## Security Features

### JWT Authentication
- Secure token generation and validation
- Configurable expiration time
- BCrypt password hashing

### CORS Configuration
- Configured for cross-origin requests
- Supports Flutter web and mobile apps

### Input Validation
- Bean Validation for all DTOs
- Comprehensive error handling
- SQL injection prevention

## Production Deployment

### Docker Deployment
Create `Dockerfile`:

```dockerfile
FROM openjdk:17-jre-slim
COPY target/bluemoon-backend-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

Build and run:
```bash
docker build -t bluemoon-backend .
docker run -p 8080:8080 bluemoon-backend
```

### Environment Variables
For production, use environment variables:

```bash
export SPRING_DATASOURCE_URL=jdbc:mysql://prod-db:3306/apartment_management_db
export SPRING_DATASOURCE_USERNAME=prod_user
export SPRING_DATASOURCE_PASSWORD=secure_password
export APP_JWT_SECRET=very_secure_production_secret
```

## Monitoring and Logging

### Health Checks
- Spring Boot Actuator endpoints available
- Database connectivity monitoring
- Application health status

### Logging
- Configurable logging levels
- Request/response logging
- Error tracking and reporting

## Performance Considerations

### Database Optimization
- Connection pooling configured
- Optimized queries with proper indexing
- Lazy loading for related entities

### Caching
- Ready for Redis integration
- Service-level caching support
- Query result caching

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   - Check MySQL server is running
   - Verify connection credentials
   - Ensure database exists

2. **JWT Token Issues**
   - Check JWT secret configuration
   - Verify token expiration settings
   - Ensure proper token format

3. **CORS Errors**
   - Verify CORS configuration
   - Check allowed origins
   - Ensure proper headers

### Debug Mode
Run with debug logging:
```bash
java -jar target/bluemoon-backend-0.0.1-SNAPSHOT.jar --logging.level.com.bluemoon=DEBUG
```

## Migration from Node.js

### Zero-Downtime Migration
1. Deploy Spring Boot backend on different port
2. Test all endpoints with existing frontend
3. Update frontend configuration
4. Switch traffic to Spring Boot backend
5. Decommission Node.js backend

### Data Migration
No data migration required - both backends use the same MySQL schema.

## Support and Maintenance

### Code Structure
- Clean layered architecture
- Comprehensive documentation
- Type-safe implementation
- Extensive error handling

### Future Enhancements
- Easy to add new features
- Scalable architecture
- Microservices-ready design
- Cloud deployment ready

---

## ✅ Verification Checklist

- [x] All compilation errors resolved
- [x] All 25+ API endpoints implemented
- [x] Complete compatibility with Node.js API
- [x] Flutter frontend compatibility verified
- [x] MySQL database integration working
- [x] JWT authentication implemented
- [x] CORS configuration complete
- [x] Error handling comprehensive
- [x] Production build successful
- [x] Documentation complete

**The Spring Boot backend is production-ready and can be deployed immediately!** 