package config

import (
	"log"
	"os"
	"strconv"
)

// Config holds application configuration
type Config struct {
	Environment string
	Port        int

	// MySQL configuration
	MySQLHost     string
	MySQLPort     int
	MySQLUser     string
	MySQLPassword string
	MySQLDatabase string

	// Service URLs
	JavaServiceURL   string
	PythonServiceURL string
}

// LoadConfig loads configuration from environment variables
func LoadConfig() *Config {
	return &Config{
		Environment: getEnv("ENVIRONMENT", "development"),
		Port:        getEnvAsInt("PORT", 8081),

		// MySQL
		MySQLHost:     getEnv("MYSQL_HOST", "mysql"),
		MySQLPort:     getEnvAsInt("MYSQL_PORT", 3306),
		MySQLUser:     getEnv("MYSQL_USER", "root"),
		MySQLPassword: getEnv("MYSQL_PASSWORD", "root"),
		MySQLDatabase: getEnv("MYSQL_DATABASE", "go_service"),

		// Service URLs
		JavaServiceURL:   getEnv("JAVA_SERVICE_URL", "http://java-service:8080"),
		PythonServiceURL: getEnv("PYTHON_SERVICE_URL", "http://python-service:8082"),
	}
}

// getEnv gets environment variable or returns default value
func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}

// getEnvAsInt gets environment variable as integer or returns default value
func getEnvAsInt(key string, defaultValue int) int {
	valueStr := os.Getenv(key)
	if valueStr == "" {
		return defaultValue
	}

	value, err := strconv.Atoi(valueStr)
	if err != nil {
		log.Printf("Invalid integer value for %s: %s, using default: %d", key, valueStr, defaultValue)
		return defaultValue
	}

	return value
}
