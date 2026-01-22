# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Everything Portal is a production-ready microservices architecture running on Minikube with Istio service mesh. It includes 5 microservices (3 backend, 2 frontend) with 3 different databases, full observability stack, and Kubernetes orchestration.

## Architecture

### Service Mesh and Routing
- All external traffic flows through **Istio Ingress Gateway**
- Path-based routing via VirtualServices:
  - `/chat` → Claude Chat UI (React frontend)
  - `/admin` → Admin Dashboard (React frontend)
  - `/api/python/*` → Python Service (FastAPI + MongoDB/PostgreSQL)
  - `/api/go/*` → Go Service (Gin + MySQL)
  - `/api/java/*` → Java Service (Spring Boot + PostgreSQL)
- Istio sidecar proxies auto-injected in default namespace
- mTLS configured in PERMISSIVE mode
- Circuit breakers and connection pooling defined in DestinationRules

### Database Architecture
- **PostgreSQL**: Used by Java Service (`java_db`) and Python Service (`python_db`)
- **MySQL**: Used by Go Service (`go_service` database)
- **MongoDB**: Used by Python Service (`python_service` database)
- All databases run as StatefulSets with persistent volumes (5Gi each)

### Service Communication
- Services communicate via Kubernetes service discovery (ClusterIP)
- Istio provides traffic management, retries, timeouts, and circuit breaking
- Health checks on `/health` (Java), `/api/go/health` (Go), `/api/python/health` (Python)

## Common Development Commands

### Environment Setup
```bash
# Start Minikube cluster (required for everything else)
./operations/scripts/start-minikube.sh

# Install Istio service mesh
./operations/scripts/install-istio.sh

# Configure Docker to use Minikube's daemon (run in every new terminal)
eval $(minikube docker-env)
```

### Building Services
```bash
# Build all services (uses Minikube's Docker)
./operations/scripts/build-all.sh

# Build individual service
docker build -t python-service:latest apps/backend/python-service
docker build -t go-service:latest apps/backend/go-service
docker build -t java-service:latest apps/backend/java-service
docker build -t claude-chat:latest apps/frontend/claude-chat
docker build -t secondary-ui:latest apps/frontend/secondary-ui
```

### Deployment
```bash
# Deploy everything (databases + services + Istio configs)
./operations/scripts/deploy-all.sh

# Deploy specific service
kubectl apply -f infrastructure/kubernetes/base/python-service/
kubectl apply -f infrastructure/kubernetes/base/go-service/
kubectl apply -f infrastructure/kubernetes/base/java-service/

# Restart a deployment after rebuilding image
kubectl rollout restart deployment python-service
kubectl rollout restart deployment go-service
kubectl rollout restart deployment java-service
```

### Testing

#### Python Service
```bash
cd apps/backend/python-service

# Run all tests
pytest

# Run with coverage
pytest --cov=app --cov-report=html

# Run specific test file
pytest tests/test_data.py

# Run in watch mode for development
pytest -f
```

#### Go Service
```bash
cd apps/backend/go-service

# Run all tests
go test ./...

# Run with verbose output
go test -v ./...

# Run specific package tests
go test ./handlers

# Run with coverage
go test -cover ./...
```

#### Java Service
```bash
cd apps/backend/java-service

# Run all tests
./mvnw test

# Run specific test class
./mvnw test -Dtest=ProductControllerTest

# Run with coverage report
./mvnw test jacoco:report
```

#### Frontend Services
```bash
cd apps/frontend/claude-chat  # or secondary-ui

# Run tests
npm test

# Run tests in CI mode
npm test -- --watchAll=false

# Run with coverage
npm test -- --coverage
```

### Running Services Locally

#### Python Service
```bash
cd apps/backend/python-service

# Install dependencies
pip install -r requirements.txt

# Run with hot reload
python -m uvicorn main:app --reload --port 8082

# Run in development mode
python main.py
```

#### Go Service
```bash
cd apps/backend/go-service

# Install dependencies
go mod download

# Run service
go run main.go

# Build binary
go build -o go-service
./go-service
```

#### Java Service
```bash
cd apps/backend/java-service

# Run with Maven
./mvnw spring-boot:run

# Build JAR
./mvnw clean package

# Run JAR
java -jar target/java-service-1.0.0.jar
```

#### Frontend Services
```bash
cd apps/frontend/claude-chat  # or secondary-ui

# Install dependencies
npm install

# Run development server
npm start  # Runs on port 3000 or 3001

# Build for production
npm run build

# Lint code
npm run lint

# Format code
npm run format
```

### Code Quality

#### Python
```bash
cd apps/backend/python-service

# Format code with black
black app/

# Sort imports
isort app/

# Lint with flake8
flake8 app/

# Type check with mypy
mypy app/
```

#### JavaScript/TypeScript
```bash
cd apps/frontend/claude-chat  # or secondary-ui

# Lint
npm run lint

# Format with prettier
npm run format
```

### Kubernetes Operations
```bash
# View all pods
kubectl get pods

# View logs for a service
kubectl logs -f deployment/python-service
kubectl logs -f deployment/python-service -c python-service  # specific container
./operations/scripts/view-logs.sh python-service

# Get shell in running pod
kubectl exec -it deployment/python-service -- /bin/bash

# Port forward to service (bypass Istio)
kubectl port-forward svc/python-service 8082:8082

# Scale service
kubectl scale deployment python-service --replicas=3

# View service details
kubectl describe deployment python-service
kubectl describe svc python-service

# Check pod events
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Istio Operations
```bash
# Get Istio Gateway URL
./operations/scripts/get-gateway-url.sh

# Analyze Istio configuration
istioctl analyze

# View proxy configuration
istioctl proxy-config routes deployment/python-service

# Check proxy status
istioctl proxy-status

# View Kiali (service mesh visualization)
kubectl port-forward -n istio-system svc/kiali 20001:20001
# Open http://localhost:20001

# View Jaeger (distributed tracing)
kubectl port-forward -n istio-system svc/tracing 16686:16686
# Open http://localhost:16686

# View Grafana (metrics dashboards)
kubectl port-forward -n istio-system svc/grafana 3000:3000
# Open http://localhost:3000

# View Prometheus (metrics)
kubectl port-forward -n istio-system svc/prometheus 9090:9090
# Open http://localhost:9090
```

### Database Operations
```bash
# Connect to PostgreSQL
kubectl exec -it statefulset/postgresql -- psql -U postgres -d java_db

# Connect to MySQL
kubectl exec -it statefulset/mysql -- mysql -u root -p

# Connect to MongoDB
kubectl exec -it statefulset/mongodb -- mongosh
```

### Cleanup
```bash
# Remove all deployments (keeps Minikube running)
./operations/scripts/cleanup.sh

# Stop Minikube
minikube stop

# Delete Minikube cluster completely
minikube delete
```

## Key File Locations

### Service Entry Points
- **Python Service**: `apps/backend/python-service/main.py` (FastAPI app)
- **Go Service**: `apps/backend/go-service/main.go` (Gin router setup)
- **Java Service**: `apps/backend/java-service/src/main/java/com/everythingportal/javaservice/JavaServiceApplication.java`
- **Claude Chat**: `apps/frontend/claude-chat/src/App.tsx`
- **Admin Dashboard**: `apps/frontend/secondary-ui/src/App.tsx`

### Kubernetes Manifests
- **Base manifests**: `infrastructure/kubernetes/base/<service>/`
  - Each service has: deployment.yaml, service.yaml
  - Databases have: statefulset.yaml, service.yaml, pvc.yaml, secrets.yaml, configmap.yaml
- **Istio configs**: `infrastructure/kubernetes/istio/`
  - gateway.yaml, virtual-services.yaml, destination-rules.yaml, peer-authentication.yaml

### Service Structure Patterns

**Python Service** (FastAPI):
- `app/routers/` - API route handlers
- `app/services/` - Business logic
- `app/models/` - Pydantic models
- `app/database/` - Database connection managers
- `app/config.py` - Settings and environment variables
- `tests/` - pytest test suite

**Go Service** (Gin):
- `handlers/` - HTTP handlers
- `routes/` - Route definitions
- `models/` - Data models
- `database/` - Database connection and operations
- `config/` - Configuration
- `middleware/` - Custom middleware

**Java Service** (Spring Boot):
- `src/main/java/.../controller/` - REST controllers
- `src/main/java/.../service/` - Business logic services
- `src/main/java/.../repository/` - JPA repositories
- `src/main/java/.../model/` - Entity models
- `src/test/` - JUnit test suite

## Important Configuration Notes

### Docker Image Names
- Images must be tagged as `<service>:latest` to match Kubernetes deployment manifests
- Always run `eval $(minikube docker-env)` before building to ensure images are in Minikube's registry

### Service Ports
- Python Service: 8082
- Go Service: 8081
- Java Service: 8080 (HTTP), 9090 (gRPC)
- Claude Chat: 3000 (dev), 80 (container)
- Secondary UI: 3001 (dev), 80 (container)

### Database Credentials
Stored in Kubernetes secrets at `infrastructure/kubernetes/base/databases/secrets.yaml`:
- PostgreSQL: user `postgres`, password `postgres123`
- MySQL: root password `mysql123`, user `go_user`, password `go123`
- MongoDB: root username `admin`, password `mongo123`

### Health Check Endpoints
Services are monitored via Kubernetes liveness/readiness probes:
- Python: `GET /api/python/health`
- Go: `GET /api/go/health`
- Java: `GET /actuator/health`

## Typical Development Workflow

1. **Make code changes** to service files
2. **Rebuild Docker image**: `docker build -t <service>:latest apps/backend/<service>`
3. **Restart deployment**: `kubectl rollout restart deployment <service>`
4. **Watch rollout**: `kubectl rollout status deployment <service>`
5. **Test via Gateway**: `curl http://<GATEWAY_URL>/api/<service>/health`
6. **View logs**: `kubectl logs -f deployment/<service>`

## Troubleshooting Tips

### Pods Not Starting
- Check events: `kubectl describe pod <pod-name>`
- Verify image exists: `docker images | grep <service>`
- Ensure `eval $(minikube docker-env)` was run before building

### Services Not Accessible via Gateway
- Verify Istio Gateway: `kubectl get gateway`
- Check VirtualServices: `kubectl get virtualservice`
- Analyze Istio: `istioctl analyze`
- Check routes: `istioctl proxy-config routes deployment/istio-ingressgateway -n istio-system`

### Database Connection Issues
- Verify database pod is running: `kubectl get pods | grep -E "postgres|mysql|mongo"`
- Check service DNS: `kubectl exec -it deployment/<service> -- nslookup postgresql`
- View database logs: `kubectl logs statefulset/postgresql`

### Istio Sidecar Not Injected
- Check namespace label: `kubectl get namespace default --show-labels`
- Add label if missing: `kubectl label namespace default istio-injection=enabled`
- Restart pods: `kubectl rollout restart deployment <service>`
