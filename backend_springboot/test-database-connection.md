# Quick Database Connection Test Guide

## Prerequisites
1. Ensure your MySQL database is running
2. Create the database and tables as specified in the main README
3. Set up your environment variables (DB_HOST, DB_USER, DB_PASSWORD, etc.)

## Test Steps

### 1. Start the Application
```bash
cd backend_springboot
mvn clean install
mvn spring-boot:run
```

### 2. Test Health Check
```bash
curl http://localhost:3001/api/test/health
```
Expected: `{"status":"UP","message":"BlueMoon Spring Boot Backend is running",...}`

### 3. Test Database Connection
```bash
curl http://localhost:3001/api/test/database
```
Expected: `{"status":"SUCCESS","message":"Database connection successful",...}`

### 4. Test Table Access
```bash
curl http://localhost:3001/api/test/tables
```
Expected: `{"status":"SUCCESS","table_counts":{"staff":0,"apartments":0,...}}`

### 5. Test Authentication (Register)
```bash
curl -X POST http://localhost:3001/api/auth/staff/register \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Test User",
    "email": "test@bluemoon.com",
    "password": "password123",
    "phone_number": "0123456789",
    "status": "active"
  }'
```
Expected: `{"message":"Staff registered successfully","staffId":1}`

### 6. Test Authentication (Login)
```bash
curl -X POST http://localhost:3001/api/auth/staff/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@bluemoon.com",
    "password": "password123"
  }'
```
Expected: `{"token":"eyJ...","staff":{"staff_id":"1",...}}`

## Troubleshooting
- If connection fails, check MySQL is running and credentials are correct
- If table access fails, ensure all tables are created in the database
- If authentication fails, check password encoding and JWT configuration 