package com.bluemoon.controller;

import com.bluemoon.dto.ApartmentDto;
import com.bluemoon.service.ApartmentService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/management/apartments")
@CrossOrigin(origins = "*")
public class ApartmentController {

    @Autowired
    private ApartmentService apartmentService;

    // POST /api/management/apartments - Create a new apartment
    @PostMapping
    public ResponseEntity<?> createApartment(@Valid @RequestBody ApartmentDto apartmentDto) {
        try {
            ApartmentDto createdApartment = apartmentService.createApartment(apartmentDto);
            return ResponseEntity.ok(createdApartment);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }

    // GET /api/management/apartments - Get all apartments
    @GetMapping
    public ResponseEntity<?> getAllApartments(@RequestParam(required = false) String status,
                                             @RequestParam(required = false) String search) {
        try {
            List<ApartmentDto> apartments = apartmentService.getAllApartments(status, search);
            return ResponseEntity.ok(apartments);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }

    // GET /api/management/apartments/:id - Get a single apartment by ID
    @GetMapping("/{id}")
    public ResponseEntity<?> getApartmentById(@PathVariable String id) {
        try {
            ApartmentDto apartment = apartmentService.getApartmentById(id);
            return ResponseEntity.ok(apartment);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }

    // PUT /api/management/apartments/:id - Update an apartment by ID
    @PutMapping("/{id}")
    public ResponseEntity<?> updateApartment(@PathVariable String id, @Valid @RequestBody ApartmentDto apartmentDto) {
        try {
            Map<String, Object> response = apartmentService.updateApartment(id, apartmentDto);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }

    // DELETE /api/management/apartments/:id - Delete an apartment by ID
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteApartment(@PathVariable String id) {
        try {
            Map<String, Object> response = apartmentService.deleteApartment(id);
        return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "status", "error",
                "message", e.getMessage()
            ));
        }
    }
} 