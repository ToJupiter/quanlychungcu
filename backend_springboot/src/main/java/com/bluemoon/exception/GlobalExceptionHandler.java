package com.bluemoon.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.WebRequest;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@ControllerAdvice
public class GlobalExceptionHandler {
    
    // Error response format matching Node.js backend
    private Map<String, Object> createErrorResponse(String status, int statusCode, String message) {
        Map<String, Object> errorResponse = new HashMap<>();
        errorResponse.put("status", status);
        errorResponse.put("statusCode", statusCode);
        errorResponse.put("message", message);
        errorResponse.put("timestamp", LocalDateTime.now().toString());
        return errorResponse;
    }
    
    // Handle resource not found
    @ExceptionHandler(CustomException.ResourceNotFoundException.class)
    public ResponseEntity<Map<String, Object>> handleResourceNotFoundException(
            CustomException.ResourceNotFoundException ex, WebRequest request) {
        Map<String, Object> errorResponse = createErrorResponse("error", 404, ex.getMessage());
        return new ResponseEntity<>(errorResponse, HttpStatus.NOT_FOUND);
    }
    
    // Handle bad request
    @ExceptionHandler(CustomException.BadRequestException.class)
    public ResponseEntity<Map<String, Object>> handleBadRequestException(
            CustomException.BadRequestException ex, WebRequest request) {
        Map<String, Object> errorResponse = createErrorResponse("error", 400, ex.getMessage());
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }
    
    // Handle duplicate resource
    @ExceptionHandler(CustomException.DuplicateResourceException.class)
    public ResponseEntity<Map<String, Object>> handleDuplicateResourceException(
            CustomException.DuplicateResourceException ex, WebRequest request) {
        Map<String, Object> errorResponse = createErrorResponse("error", 409, ex.getMessage());
        return new ResponseEntity<>(errorResponse, HttpStatus.CONFLICT);
    }
    
    // Handle authentication errors
    @ExceptionHandler(CustomException.AuthenticationException.class)
    public ResponseEntity<Map<String, Object>> handleAuthenticationException(
            CustomException.AuthenticationException ex, WebRequest request) {
        Map<String, Object> errorResponse = createErrorResponse("error", 401, ex.getMessage());
        return new ResponseEntity<>(errorResponse, HttpStatus.UNAUTHORIZED);
    }
    
    // Handle authorization errors
    @ExceptionHandler(CustomException.AuthorizationException.class)
    public ResponseEntity<Map<String, Object>> handleAuthorizationException(
            CustomException.AuthorizationException ex, WebRequest request) {
        Map<String, Object> errorResponse = createErrorResponse("error", 403, ex.getMessage());
        return new ResponseEntity<>(errorResponse, HttpStatus.FORBIDDEN);
    }
    
    // Handle validation errors
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidationExceptions(
            MethodArgumentNotValidException ex) {
        Map<String, Object> errorResponse = new HashMap<>();
        Map<String, String> errors = new HashMap<>();
        
        ex.getBindingResult().getAllErrors().forEach((error) -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            errors.put(fieldName, errorMessage);
        });
        
        errorResponse.put("status", "error");
        errorResponse.put("statusCode", 422);
        errorResponse.put("message", "Validation failed");
        errorResponse.put("errors", errors);
        
        return new ResponseEntity<>(errorResponse, HttpStatus.UNPROCESSABLE_ENTITY);
    }
    
    // Handle invalid data
    @ExceptionHandler(CustomException.InvalidDataException.class)
    public ResponseEntity<Map<String, Object>> handleInvalidDataException(
            CustomException.InvalidDataException ex, WebRequest request) {
        Map<String, Object> errorResponse = createErrorResponse("error", 422, ex.getMessage());
        return new ResponseEntity<>(errorResponse, HttpStatus.UNPROCESSABLE_ENTITY);
    }
    
    // Handle general exceptions
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleGlobalException(
            Exception ex, WebRequest request) {
        Map<String, Object> errorResponse = createErrorResponse("error", 500, 
            "Internal server error: " + ex.getMessage());
        return new ResponseEntity<>(errorResponse, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<Map<String, Object>> handleRuntimeException(RuntimeException ex, WebRequest request) {
        Map<String, Object> errorResponse = new HashMap<>();
        errorResponse.put("status", "error");
        errorResponse.put("statusCode", 400);
        errorResponse.put("message", ex.getMessage());
        
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }
    
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, Object>> handleIllegalArgumentException(IllegalArgumentException ex) {
        Map<String, Object> errorResponse = new HashMap<>();
        errorResponse.put("status", "error");
        errorResponse.put("statusCode", 400);
        errorResponse.put("message", ex.getMessage());
        
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }
    
    @ExceptionHandler(NumberFormatException.class)
    public ResponseEntity<Map<String, Object>> handleNumberFormatException(NumberFormatException ex) {
        Map<String, Object> errorResponse = new HashMap<>();
        errorResponse.put("status", "error");
        errorResponse.put("statusCode", 400);
        errorResponse.put("message", "Invalid ID format");
        
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }
} 