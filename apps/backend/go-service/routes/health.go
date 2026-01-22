package routes

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"go-service/database"
)

// SetupHealthRoutes sets up health check routes
func SetupHealthRoutes(router *gin.Engine) {
	health := router.Group("/api/go/health")
	{
		health.GET("/", healthCheck)
		health.GET("/ready", readinessCheck)
		health.GET("/live", livenessCheck)
	}
}

// healthCheck handles basic health check
func healthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status":    "healthy",
		"timestamp": time.Now().UTC().Format(time.RFC3339),
		"service":   "go-service",
	})
}

// readinessCheck handles readiness check with database connectivity
func readinessCheck(c *gin.Context) {
	checks := gin.H{
		"status":    "ready",
		"timestamp": time.Now().UTC().Format(time.RFC3339),
		"checks":    gin.H{},
	}

	// Check MySQL connection
	db := database.GetDB()
	if db != nil {
		sqlDB, err := db.DB()
		if err != nil {
			checks["checks"].(gin.H)["mysql"] = "error: " + err.Error()
			checks["status"] = "not ready"
		} else if err := sqlDB.Ping(); err != nil {
			checks["checks"].(gin.H)["mysql"] = "error: " + err.Error()
			checks["status"] = "not ready"
		} else {
			checks["checks"].(gin.H)["mysql"] = "connected"
		}
	} else {
		checks["checks"].(gin.H)["mysql"] = "not initialized"
		checks["status"] = "not ready"
	}

	statusCode := http.StatusOK
	if checks["status"] != "ready" {
		statusCode = http.StatusServiceUnavailable
	}

	c.JSON(statusCode, checks)
}

// livenessCheck handles liveness check
func livenessCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status":    "alive",
		"timestamp": time.Now().UTC().Format(time.RFC3339),
	})
}
