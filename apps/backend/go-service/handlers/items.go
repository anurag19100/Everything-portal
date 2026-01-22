package handlers

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"go-service/database"
)

// Item represents a data item
type Item struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	Name      string    `json:"name" gorm:"not null"`
	Value     float64   `json:"value"`
	Active    bool      `json:"active" gorm:"default:true"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// CreateItemRequest represents create item request
type CreateItemRequest struct {
	Name   string  `json:"name" binding:"required"`
	Value  float64 `json:"value" binding:"required"`
	Active *bool   `json:"active"`
}

// UpdateItemRequest represents update item request
type UpdateItemRequest struct {
	Name   string  `json:"name"`
	Value  float64 `json:"value"`
	Active *bool   `json:"active"`
}

// GetItems retrieves all items
func GetItems(c *gin.Context) {
	var items []Item
	db := database.GetDB()

	// Pagination
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	offset := (page - 1) * limit

	if err := db.Offset(offset).Limit(limit).Find(&items).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch items"})
		return
	}

	var total int64
	db.Model(&Item{}).Count(&total)

	c.JSON(http.StatusOK, gin.H{
		"items": items,
		"total": total,
		"page":  page,
		"limit": limit,
	})
}

// GetItem retrieves a single item by ID
func GetItem(c *gin.Context) {
	id := c.Param("id")
	var item Item
	db := database.GetDB()

	if err := db.First(&item, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Item not found"})
		return
	}

	c.JSON(http.StatusOK, item)
}

// CreateItem creates a new item
func CreateItem(c *gin.Context) {
	var req CreateItemRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	active := true
	if req.Active != nil {
		active = *req.Active
	}

	item := Item{
		Name:   req.Name,
		Value:  req.Value,
		Active: active,
	}

	db := database.GetDB()
	if err := db.Create(&item).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create item"})
		return
	}

	c.JSON(http.StatusCreated, item)
}

// UpdateItem updates an existing item
func UpdateItem(c *gin.Context) {
	id := c.Param("id")
	var item Item
	db := database.GetDB()

	if err := db.First(&item, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Item not found"})
		return
	}

	var req UpdateItemRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Update fields
	if req.Name != "" {
		item.Name = req.Name
	}
	if req.Value != 0 {
		item.Value = req.Value
	}
	if req.Active != nil {
		item.Active = *req.Active
	}

	if err := db.Save(&item).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update item"})
		return
	}

	c.JSON(http.StatusOK, item)
}

// DeleteItem deletes an item
func DeleteItem(c *gin.Context) {
	id := c.Param("id")
	db := database.GetDB()

	if err := db.Delete(&Item{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete item"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Item deleted successfully"})
}

// Initialize auto-migrates the Item model
func Initialize() {
	db := database.GetDB()
	db.AutoMigrate(&Item{})
}
