package com.bluemoon;

import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.*;
import org.springframework.test.context.ActiveProfiles;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class BlackBoxIntegrationTest {
    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    private static String adminToken;
    private static String accountantToken;
    private static String testStaffId;
    private static String testHouseholdId;
    private static String testResidentId;
    private static String testVehicleId;
    private static String testPaymentId;

    private String getBaseUrl() {
        return "http://localhost:" + port + "/api";
    }

    @Test
    @Order(1)
    void testRegisterAdmin() {
        Map<String, Object> payload = new HashMap<>();
        payload.put("email", "admin@bluemoon.com");
        payload.put("password", "AdminPass123");
        payload.put("full_name", "Admin User");
        payload.put("phone_number", "0123456789");
        payload.put("status", "active");
        ResponseEntity<Map<String, Object>> resp = restTemplate.postForEntity(getBaseUrl() + "/auth/staff/register", payload, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
    }

    @Test
    @Order(2)
    void testRegisterAccountant() {
        Map<String, Object> payload = new HashMap<>();
        payload.put("email", "accountant@bluemoon.com");
        payload.put("password", "AccountantPass123");
        payload.put("full_name", "Accountant User");
        payload.put("phone_number", "0123456790");
        payload.put("status", "active");
        ResponseEntity<Map<String, Object>> resp = restTemplate.postForEntity(getBaseUrl() + "/auth/staff/register", payload, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
    }

    @Test
    @Order(3)
    void testAdminLogin() {
        adminToken = loginAndGetToken("admin@bluemoon.com", "AdminPass123");
        assertThat(adminToken).isNotNull();
    }

    @Test
    @Order(4)
    void testAccountantLogin() {
        accountantToken = loginAndGetToken("accountant@bluemoon.com", "AccountantPass123");
        assertThat(accountantToken).isNotNull();
    }

    @Test
    @Order(5)
    void testAddStaff() {
        Map<String, Object> payload = new HashMap<>();
        payload.put("email", "staff1@bluemoon.com");
        payload.put("password", "StaffPass123");
        payload.put("full_name", "Staff One");
        payload.put("phone_number", "0123456791");
        payload.put("status", "active");
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);
        ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(getBaseUrl() + "/staff", HttpMethod.POST, entity, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
        testStaffId = resp.getBody() != null ? (String) resp.getBody().get("staffId") : null;
    }

    @Test
    @Order(6)
    void testGetStaffList() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        HttpEntity<Void> entity = new HttpEntity<>(headers);
        ResponseEntity<List> resp = restTemplate.exchange(getBaseUrl() + "/staff", HttpMethod.GET, entity, List.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(resp.getBody()).isNotNull();
    }

    @Test
    @Order(7)
    void testGetStaffById() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        HttpEntity<Void> entity = new HttpEntity<>(headers);
        ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(getBaseUrl() + "/staff/" + testStaffId, HttpMethod.GET, entity, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
    }

    @Test
    @Order(8)
    void testUpdateStaffStatus() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        Map<String, String> payload = new HashMap<>();
        payload.put("status", "inactive");
        HttpEntity<Map<String, String>> entity = new HttpEntity<>(payload, headers);
        ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(getBaseUrl() + "/staff/" + testStaffId + "/status", HttpMethod.PATCH, entity, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
    }

    @Test
    @Order(9)
    void testResetStaffPassword() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        Map<String, String> payload = new HashMap<>();
        payload.put("password", "NewStaffPass123");
        HttpEntity<Map<String, String>> entity = new HttpEntity<>(payload, headers);
        ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(getBaseUrl() + "/staff/" + testStaffId + "/reset-password", HttpMethod.PATCH, entity, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
    }

    @Test
    @Order(10)
    void testDeleteStaff() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        HttpEntity<Void> entity = new HttpEntity<>(headers);
        ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(getBaseUrl() + "/staff/" + testStaffId, HttpMethod.DELETE, entity, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
    }

    @Test
    @Order(11)
    void testAddHousehold() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        Map<String, Object> payload = new HashMap<>();
        payload.put("apartment_id", null);
        payload.put("head_full_name", "Nguyen Van A");
        payload.put("head_cccd", "002288884444");
        payload.put("apartment_number", "101");
        payload.put("apartment_area", 100);
        payload.put("apartment_status", "active");
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);
        ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(getBaseUrl() + "/management/households", HttpMethod.POST, entity, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
        testHouseholdId = resp.getBody() != null ? (String) resp.getBody().get("household_id") : null;
    }

    @Test
    @Order(12)
    void testGetHouseholdList() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        HttpEntity<Void> entity = new HttpEntity<>(headers);
        ResponseEntity<List> resp = restTemplate.exchange(getBaseUrl() + "/management/households", HttpMethod.GET, entity, List.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(resp.getBody()).isNotNull();
    }

    @Test
    @Order(13)
    void testGetHouseholdById() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        HttpEntity<Void> entity = new HttpEntity<>(headers);
        ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(getBaseUrl() + "/management/households/" + testHouseholdId, HttpMethod.GET, entity, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
    }

    @Test
    @Order(14)
    void testAddResident() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        Map<String, Object> payload = new HashMap<>();
        payload.put("full_name", "Nguyen Van B");
        payload.put("date_of_birth", "1990-01-01");
        payload.put("cccd_number", "002288884445");
        payload.put("role_in_household", "Member");
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);
        ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(getBaseUrl() + "/management/households/" + testHouseholdId + "/residents", HttpMethod.POST, entity, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
        testResidentId = resp.getBody() != null ? (String) resp.getBody().get("resident_id") : null;
    }

    @Test
    @Order(15)
    void testGetResidentsByHousehold() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        HttpEntity<Void> entity = new HttpEntity<>(headers);
        ResponseEntity<List> resp = restTemplate.exchange(getBaseUrl() + "/management/households/" + testHouseholdId + "/residents", HttpMethod.GET, entity, List.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(resp.getBody()).isNotNull();
    }

    @Test
    @Order(16)
    void testUpdateResident() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        Map<String, Object> payload = new HashMap<>();
        payload.put("full_name", "Nguyen Van B Updated");
        payload.put("date_of_birth", "1990-01-01");
        payload.put("cccd_number", "002288884445");
        payload.put("role_in_household", "Member");
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);
        ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(getBaseUrl() + "/management/residents/" + testResidentId, HttpMethod.PUT, entity, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
    }

    @Test
    @Order(17)
    void testDeleteResident() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        HttpEntity<Void> entity = new HttpEntity<>(headers);
        ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(getBaseUrl() + "/management/residents/" + testResidentId, HttpMethod.DELETE, entity, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
    }

    @Test
    @Order(18)
    void testAddVehicle() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        Map<String, Object> payload = new HashMap<>();
        payload.put("plate_number", "30A-98899");
        payload.put("vehicle_type", "Car");
        payload.put("registration_date", "2024-01-01");
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);
        ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(getBaseUrl() + "/management/households/" + testHouseholdId + "/vehicles", HttpMethod.POST, entity, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
        testVehicleId = resp.getBody() != null ? (String) resp.getBody().get("vehicle_id") : null;
    }

    @Test
    @Order(19)
    void testGetVehiclesByHousehold() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        HttpEntity<Void> entity = new HttpEntity<>(headers);
        ResponseEntity<List> resp = restTemplate.exchange(getBaseUrl() + "/management/households/" + testHouseholdId + "/vehicles", HttpMethod.GET, entity, List.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(resp.getBody()).isNotNull();
    }

    @Test
    @Order(20)
    void testUpdateVehicle() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        Map<String, Object> payload = new HashMap<>();
        payload.put("plate_number", "30A-98899");
        payload.put("vehicle_type", "Car");
        payload.put("registration_date", "2024-01-02");
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);
        ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(getBaseUrl() + "/management/vehicles/" + testVehicleId, HttpMethod.PUT, entity, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
    }

    @Test
    @Order(21)
    void testDeleteVehicle() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        HttpEntity<Void> entity = new HttpEntity<>(headers);
        ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(getBaseUrl() + "/management/vehicles/" + testVehicleId, HttpMethod.DELETE, entity, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
    }

    @Test
    @Order(22)
    void testCreatePayment() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        Map<String, Object> payload = new HashMap<>();
        payload.put("household_id", testHouseholdId);
        payload.put("payment_type", "Tiền điện");
        payload.put("amount", 500000);
        payload.put("due_date", "2024-12-31");
        payload.put("status", "unpaid");
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);
        ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(getBaseUrl() + "/finance/payments", HttpMethod.POST, entity, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
        testPaymentId = resp.getBody() != null ? (String) resp.getBody().get("payment_id") : null;
    }

    @Test
    @Order(23)
    void testGetPaymentsByHousehold() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        HttpEntity<Void> entity = new HttpEntity<>(headers);
        ResponseEntity<List> resp = restTemplate.exchange(getBaseUrl() + "/finance/households/" + testHouseholdId + "/payments", HttpMethod.GET, entity, List.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(resp.getBody()).isNotNull();
    }

    @Test
    @Order(24)
    void testUpdatePaymentStatus() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        Map<String, String> payload = new HashMap<>();
        payload.put("status", "paid");
        payload.put("payment_date", "2024-12-31");
        HttpEntity<Map<String, String>> entity = new HttpEntity<>(payload, headers);
        ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(getBaseUrl() + "/finance/payments/" + testPaymentId + "/status", HttpMethod.PATCH, entity, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
    }

    @Test
    @Order(25)
    void testUpdatePayment() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        Map<String, Object> payload = new HashMap<>();
        payload.put("household_id", testHouseholdId);
        payload.put("payment_type", "Tiền nước");
        payload.put("amount", 300000);
        payload.put("due_date", "2024-12-31");
        payload.put("status", "paid");
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);
        ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(getBaseUrl() + "/finance/payments/" + testPaymentId, HttpMethod.PUT, entity, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
    }

    @Test
    @Order(26)
    void testDeletePayment() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        HttpEntity<Void> entity = new HttpEntity<>(headers);
        ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(getBaseUrl() + "/finance/payments/" + testPaymentId, HttpMethod.DELETE, entity, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
    }

    @Test
    @Order(27)
    void testGetAnalyticsDashboard() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        HttpEntity<Void> entity = new HttpEntity<>(headers);
        ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(getBaseUrl() + "/analytics/dashboard", HttpMethod.GET, entity, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
    }

    @Test
    @Order(28)
    void testGetFinancialOverview() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accountantToken);
        HttpEntity<Void> entity = new HttpEntity<>(headers);
        ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(getBaseUrl() + "/analytics/financial/overview", HttpMethod.GET, entity, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
    }

    @Test
    @Order(29)
    void testGetGeneralOverview() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accountantToken);
        HttpEntity<Void> entity = new HttpEntity<>(headers);
        ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(getBaseUrl() + "/analytics/general/overview", HttpMethod.GET, entity, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
    }

    @Test
    @Order(30)
    void testChangePassword() {
        Map<String, Object> payload = new HashMap<>();
        payload.put("email", "admin@bluemoon.com");
        payload.put("oldPassword", "AdminPass123");
        payload.put("newPassword", "AdminPass456");
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(adminToken);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);
        ResponseEntity<Map<String, Object>> resp = restTemplate.exchange(getBaseUrl() + "/auth/staff/change-password", HttpMethod.POST, entity, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
    }

    private String loginAndGetToken(String email, String password) {
        Map<String, Object> loginPayload = new HashMap<>();
        loginPayload.put("email", email);
        loginPayload.put("password", password);
        ResponseEntity<Map<String, Object>> loginResp = restTemplate.postForEntity(getBaseUrl() + "/auth/staff/login", loginPayload, (Class<Map<String, Object>>)(Class<?>)Map.class);
        assertThat(loginResp.getStatusCode().is2xxSuccessful()).isTrue();
        return loginResp.getBody() != null ? (String) loginResp.getBody().get("token") : null;
    }
}
