package routes

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"go-service/handlers"
)

// SetupAPIRoutes sets up API routes
func SetupAPIRoutes(router *gin.Engine) {
	api := router.Group("/api/go")
	{
		// Items endpoints
		items := api.Group("/items")
		{
			items.GET("", handlers.GetItems)
			items.GET("/:id", handlers.GetItem)
			items.POST("", handlers.CreateItem)
			items.PUT("/:id", handlers.UpdateItem)
			items.DELETE("/:id", handlers.DeleteItem)
		}

		// Performance test endpoint
		api.GET("/performance", performanceTest)
	}
}

// performanceTest demonstrates high-performance endpoint
func performanceTest(c *gin.Context) {
	// Simulate fast response
	data := make([]map[string]interface{}, 100)
	for i := 0; i < 100; i++ {
		data[i] = map[string]interface{}{
			"id":    i,
			"value": i * 2,
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "High-performance endpoint",
		"data":    data,
		"count":   len(data),
	})
}
