# API Documentation

Complete API documentation for all Everything Portal services.

## Base URLs

When accessing through Istio Gateway:
```
http://<MINIKUBE_IP>:<GATEWAY_PORT>
```

Get your gateway URL:
```bash
./operations/scripts/get-gateway-url.sh
```

## Java Service API

**Base Path**: `/api/java`
**Port**: 8080
**Technology**: Spring Boot REST

### Endpoints

#### Health Check
```http
GET /api/java/health
```

**Response**:
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T12:00:00Z",
  "service": "java-service"
}
```

#### Readiness Check
```http
GET /api/java/health/ready
```

#### Products

##### Get All Products
```http
GET /api/java/products?active=true
```

**Query Parameters**:
- `active` (optional): Filter by active status

**Response**:
```json
[
  {
    "id": 1,
    "name": "Product 1",
    "description": "Description",
    "price": 29.99,
    "quantity": 100,
    "active": true,
    "createdAt": "2024-01-01T12:00:00Z",
    "updatedAt": "2024-01-01T12:00:00Z"
  }
]
```

##### Get Product by ID
```http
GET /api/java/products/{id}
```

**Path Parameters**:
- `id`: Product ID

**Response**: Product object or 404

##### Search Products
```http
GET /api/java/products/search?name=laptop
```

**Query Parameters**:
- `name`: Search term

##### Create Product
```http
POST /api/java/products
Content-Type: application/json

{
  "name": "New Product",
  "description": "Product description",
  "price": 49.99,
  "quantity": 50,
  "active": true
}
```

**Response**: Created product with 201 status

##### Update Product
```http
PUT /api/java/products/{id}
Content-Type: application/json

{
  "name": "Updated Product",
  "description": "Updated description",
  "price": 59.99,
  "quantity": 75,
  "active": true
}
```

##### Delete Product
```http
DELETE /api/java/products/{id}
```

**Response**: 204 No Content

---

## Go Service API

**Base Path**: `/api/go`
**Port**: 8081
**Technology**: Gin Framework

### Endpoints

#### Health Check
```http
GET /api/go/health
```

#### Items

##### Get All Items
```http
GET /api/go/items?page=1&limit=10
```

**Query Parameters**:
- `page` (default: 1): Page number
- `limit` (default: 10): Items per page

**Response**:
```json
{
  "items": [
    {
      "id": 1,
      "name": "Item 1",
      "value": 100.50,
      "active": true,
      "created_at": "2024-01-01T12:00:00Z",
      "updated_at": "2024-01-01T12:00:00Z"
    }
  ],
  "total": 42,
  "page": 1,
  "limit": 10
}
```

##### Get Item by ID
```http
GET /api/go/items/{id}
```

##### Create Item
```http
POST /api/go/items
Content-Type: application/json

{
  "name": "New Item",
  "value": 250.75,
  "active": true
}
```

##### Update Item
```http
PUT /api/go/items/{id}
Content-Type: application/json

{
  "name": "Updated Item",
  "value": 300.00,
  "active": false
}
```

##### Delete Item
```http
DELETE /api/go/items/{id}
```

#### Performance Test
```http
GET /api/go/performance
```

Returns sample data for performance testing.

---

## Python Service API

**Base Path**: `/api/python`
**Port**: 8082
**Technology**: FastAPI

### Endpoints

#### Health Check
```http
GET /api/python/health
```

#### Service Info
```http
GET /info
```

#### Data Management

##### Get All Data Items
```http
GET /api/python/data?skip=0&limit=10
```

**Query Parameters**:
- `skip` (default: 0): Number of items to skip
- `limit` (default: 10): Maximum items to return

**Response**:
```json
[
  {
    "id": "507f1f77bcf86cd799439011",
    "name": "Data Item 1",
    "value": 42.5,
    "metadata": {
      "source": "sensor-1",
      "unit": "celsius"
    },
    "created_at": "2024-01-01T12:00:00Z"
  }
]
```

##### Get Data Item
```http
GET /api/python/data/{item_id}
```

##### Create Data Item
```http
POST /api/python/data
Content-Type: application/json

{
  "name": "Temperature Reading",
  "value": 23.5,
  "metadata": {
    "sensor": "temp-sensor-1",
    "location": "server-room"
  }
}
```

##### Update Data Item
```http
PUT /api/python/data/{item_id}
Content-Type: application/json

{
  "name": "Updated Reading",
  "value": 24.0,
  "metadata": {}
}
```

##### Delete Data Item
```http
DELETE /api/python/data/{item_id}
```

#### Machine Learning

##### Make Prediction
```http
POST /api/python/ml/predict
Content-Type: application/json

{
  "features": [1.5, 2.3, 3.7]
}
```

**Response**:
```json
{
  "prediction": 7.5,
  "confidence": 0.85,
  "model": "simple-linear-v1"
}
```

##### Analyze Data
```http
POST /api/python/ml/analyze
Content-Type: application/json

{
  "data": [10, 20, 30, 40, 50]
}
```

**Response**:
```json
{
  "mean": 30.0,
  "std": 14.142,
  "min": 10.0,
  "max": 50.0,
  "count": 5
}
```

##### List ML Models
```http
GET /api/python/ml/models
```

**Response**:
```json
{
  "models": [
    {
      "name": "simple-linear-v1",
      "type": "regression",
      "status": "active",
      "version": "1.0.0"
    }
  ]
}
```

##### Train Model
```http
POST /api/python/ml/train
Content-Type: application/json

{
  "model_name": "new-model",
  "training_data": []
}
```

---

## Error Responses

All services follow a consistent error response format:

### 400 Bad Request
```json
{
  "error": "Invalid request parameters",
  "details": ["Field 'name' is required"]
}
```

### 404 Not Found
```json
{
  "error": "Resource not found",
  "details": ["Item with id '123' not found"]
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal server error",
  "details": ["Database connection failed"]
}
```

### 503 Service Unavailable
```json
{
  "error": "Service unavailable",
  "details": ["Database not ready"]
}
```

---

## Authentication

Currently, the services don't require authentication for development.

### For Production:

Implement JWT authentication:

1. **Obtain Token**:
```http
POST /auth/login
Content-Type: application/json

{
  "username": "user",
  "password": "password"
}
```

2. **Use Token**:
```http
GET /api/java/products
Authorization: Bearer <token>
```

---

## Rate Limiting

Istio DestinationRules implement connection limits:

- **Java Service**: 100 max connections
- **Go Service**: 200 max connections
- **Python Service**: 100 max connections

Circuit breaker triggers after 5 consecutive errors.

---

## CORS

All services are configured to accept requests from:
- `http://localhost:3000` (Claude Chat)
- `http://localhost:3001` (Admin Dashboard)
- Service mesh internal communication

---

## API Testing

### Using curl

```bash
# Get Gateway URL
GATEWAY_URL=$(minikube ip):$(kubectl -n istio-system get svc istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')

# Test Python Service
curl http://${GATEWAY_URL}/api/python/health

# Create data item
curl -X POST http://${GATEWAY_URL}/api/python/data \
  -H "Content-Type: application/json" \
  -d '{"name": "test", "value": 42.0}'

# Make prediction
curl -X POST http://${GATEWAY_URL}/api/python/ml/predict \
  -H "Content-Type: application/json" \
  -d '{"features": [1.0, 2.0, 3.0]}'
```

### Using HTTPie

```bash
# Install httpie
pip install httpie

# Test endpoints
http GET ${GATEWAY_URL}/api/python/health
http POST ${GATEWAY_URL}/api/python/data name="test" value:=42.0
```

### Using Postman

1. Import the Postman collection from `docs/api/postman-collection.json`
2. Set environment variable `GATEWAY_URL`
3. Run the collection

---

## OpenAPI/Swagger

### Python Service (FastAPI)

FastAPI automatically generates OpenAPI documentation:

```bash
# Access Swagger UI
kubectl port-forward svc/python-service 8082:8082
open http://localhost:8082/docs
```

### Java Service (Spring Boot)

Add Springdoc OpenAPI dependency to view Swagger UI:

```bash
kubectl port-forward svc/java-service 8080:8080
open http://localhost:8080/swagger-ui.html
```

---

## WebSocket Support

Claude Chat UI uses WebSocket for real-time communication:

```javascript
const socket = io('http://<gateway-url>');

socket.on('connect', () => {
  console.log('Connected');
});

socket.emit('message', { text: 'Hello' });

socket.on('response', (data) => {
  console.log('Received:', data);
});
```

---

## Monitoring API Health

### Prometheus Metrics

All services expose Prometheus metrics:

```bash
# Java Service
curl http://java-service:8080/actuator/prometheus

# Python Service
curl http://python-service:8082/metrics
```

### Healthcheck Endpoints

```bash
# Liveness (is the service running?)
curl http://<service>:<port>/api/<service>/health/live

# Readiness (is the service ready to handle traffic?)
curl http://<service>:<port>/api/<service>/health/ready
```

---

## Versioning

APIs are currently unversioned. For production, use URL versioning:

```
/api/v1/java/products
/api/v2/java/products
```

Or header versioning:
```
API-Version: 1
```
