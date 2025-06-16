package com.bluemoon.service;

import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class ResidentServiceTest {
    @Autowired
    private com.bluemoon.service.ResidentService residentService;

    @Test
    @Order(1)
    void testAddResident_Valid() {
        // ...test logic for adding a valid resident...
        Assertions.assertTrue(true); // placeholder
    }

    @Test
    @Order(2)
    void testAddResident_Invalid() {
        // ...test logic for adding an invalid resident...
        Assertions.assertTrue(true); // placeholder
    }

    // Add more tests as needed for CRUD and edge cases
}
