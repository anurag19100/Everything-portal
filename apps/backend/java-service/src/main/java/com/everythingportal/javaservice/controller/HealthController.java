package com.everythingportal.javaservice.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.sql.Connection;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

/**
 * Health check controller for Kubernetes probes.
 */
@RestController
@RequestMapping("/api/java/health")
public class HealthController {

    @Autowired
    private DataSource dataSource;

    @GetMapping
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "healthy");
        response.put("timestamp", Instant.now().toString());
        response.put("service", "java-service");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/ready")
    public ResponseEntity<Map<String, Object>> readiness() {
        Map<String, Object> response = new HashMap<>();
        Map<String, String> checks = new HashMap<>();

        response.put("timestamp", Instant.now().toString());

        // Check database connectivity
        try (Connection connection = dataSource.getConnection()) {
            if (connection.isValid(2)) {
                checks.put("postgresql", "connected");
                response.put("status", "ready");
            } else {
                checks.put("postgresql", "invalid connection");
                response.put("status", "not ready");
            }
        } catch (Exception e) {
            checks.put("postgresql", "error: " + e.getMessage());
            response.put("status", "not ready");
            response.put("checks", checks);
            return ResponseEntity.status(503).body(response);
        }

        response.put("checks", checks);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/live")
    public ResponseEntity<Map<String, Object>> liveness() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "alive");
        response.put("timestamp", Instant.now().toString());
        return ResponseEntity.ok(response);
    }
}
