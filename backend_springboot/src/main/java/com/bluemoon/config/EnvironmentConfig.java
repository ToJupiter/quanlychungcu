package com.bluemoon.config;

import org.springframework.context.annotation.Configuration;
import jakarta.annotation.PostConstruct;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Properties;

@Configuration
public class EnvironmentConfig {

    @PostConstruct
    public void loadEnvironmentVariables() {
        try {
            // Try to load .env file from the project root
            String envFile = ".env";
            if (Files.exists(Paths.get(envFile))) {
                Properties props = new Properties();
                props.load(new FileInputStream(envFile));
                
                // Set system properties for Spring Boot to pick up
                for (String key : props.stringPropertyNames()) {
                    String value = props.getProperty(key);
                    if (System.getProperty(key) == null) {
                        System.setProperty(key, value);
                    }
                }
                
                System.out.println("Loaded environment variables from .env file");
            } else {
                System.out.println("No .env file found, using system environment variables");
            }
        } catch (IOException e) {
            System.err.println("Failed to load .env file: " + e.getMessage());
        }
    }
} 