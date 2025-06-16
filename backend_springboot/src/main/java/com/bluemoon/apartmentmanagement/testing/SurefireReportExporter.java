package com.bluemoon.apartmentmanagement.testing;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;

import java.io.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

public class SurefireReportExporter {
    private static class TestResult {
        String testName;
        String testObject;
        String description;
        String input;
        String expectedOutput;
        String actualOutput;
        String status;
        String timestamp;

        public TestResult(String testName, String testObject, String description, 
                         String input, String expectedOutput, String actualOutput, String status) {
            this.testName = testName;
            this.testObject = testObject;
            this.description = description;
            this.input = input;
            this.expectedOutput = expectedOutput;
            this.actualOutput = actualOutput;
            this.status = status;
            this.timestamp = LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME);
        }
    }

    private List<TestResult> results = new ArrayList<>();

    public void addTestResult(String testName, String testObject, String description,
                            String input, String expectedOutput, String actualOutput, String status) {
        results.add(new TestResult(testName, testObject, description, input, expectedOutput, actualOutput, status));
    }

    public void exportToJson(String filename) throws IOException {
        ObjectMapper mapper = new ObjectMapper();
        ArrayNode arrayNode = mapper.createArrayNode();

        for (TestResult result : results) {
            ObjectNode resultNode = mapper.createObjectNode();
            resultNode.put("testName", result.testName);
            resultNode.put("testObject", result.testObject);
            resultNode.put("description", result.description);
            resultNode.put("input", result.input);
            resultNode.put("expectedOutput", result.expectedOutput);
            resultNode.put("actualOutput", result.actualOutput);
            resultNode.put("status", result.status);
            resultNode.put("timestamp", result.timestamp);
            arrayNode.add(resultNode);
        }

        mapper.writerWithDefaultPrettyPrinter().writeValue(new File(filename), arrayNode);
    }

    public void exportToCsv(String filename) throws IOException {
        try (PrintWriter writer = new PrintWriter(new File(filename))) {
            writer.println("Test Name,Test Object,Description,Input,Expected Output,Actual Output,Status,Timestamp");
            
            for (TestResult result : results) {
                writer.println(String.format("\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"",
                    escapeCsvField(result.testName),
                    escapeCsvField(result.testObject),
                    escapeCsvField(result.description),
                    escapeCsvField(result.input),
                    escapeCsvField(result.expectedOutput),
                    escapeCsvField(result.actualOutput),
                    escapeCsvField(result.status),
                    escapeCsvField(result.timestamp)));
            }
        }
    }

    private String escapeCsvField(String field) {
        return field.replace("\"", "\"\"");
    }
} 