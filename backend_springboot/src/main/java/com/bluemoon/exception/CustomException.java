package com.bluemoon.exception;

public class CustomException {
    
    // Resource not found exception
    public static class ResourceNotFoundException extends RuntimeException {
        public ResourceNotFoundException(String message) {
            super(message);
        }
        
        public ResourceNotFoundException(String resource, String field, Object value) {
            super(String.format("%s not found with %s: %s", resource, field, value));
        }
    }
    
    // Bad request exception
    public static class BadRequestException extends RuntimeException {
        public BadRequestException(String message) {
            super(message);
        }
    }
    
    // Duplicate resource exception
    public static class DuplicateResourceException extends RuntimeException {
        public DuplicateResourceException(String message) {
            super(message);
        }
        
        public DuplicateResourceException(String resource, String field, Object value) {
            super(String.format("%s already exists with %s: %s", resource, field, value));
        }
    }
    
    // Authentication exception
    public static class AuthenticationException extends RuntimeException {
        public AuthenticationException(String message) {
            super(message);
        }
    }
    
    // Authorization exception
    public static class AuthorizationException extends RuntimeException {
        public AuthorizationException(String message) {
            super(message);
        }
    }
    
    // Invalid data exception
    public static class InvalidDataException extends RuntimeException {
        public InvalidDataException(String message) {
            super(message);
        }
    }
} 