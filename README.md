# Everything Portal - Microservices Architecture

A production-ready microservices architecture with Istio service mesh, running on Minikube.

## 🚀 Quick Start

Deploy everything with one command:

```bash
./startup.sh
```

See **[QUICKSTART.md](QUICKSTART.md)** for detailed quick start guide.

**Already deployed?** Test your deployment:
```bash
./test-deployment.sh
```

## Architecture Overview

This project implements a full-stack microservices application with:

### Frontend Services
- **Claude Chat Interface** - React-based chat UI with real-time messaging
- **Secondary UI** - Admin dashboard and visualization panel

### Backend Services
- **Java Service** - Spring Boot microservice with PostgreSQL
- **Go Service** - High-performance API microservice with MySQL
- **Python Service** - FastAPI service with MongoDB and ML capabilities

### Data Layer
- **PostgreSQL** - Primary relational database
- **MySQL** - Secondary SQL database
- **MongoDB** - NoSQL document store

### Infrastructure
- **Minikube** - Local Kubernetes cluster
- **Istio** - Service mesh for traffic management, security, and observability
- **Prometheus** - Metrics collection
- **Grafana** - Metrics visualization
- **Jaeger** - Distributed tracing

## Project Structure

```
Everything-portal/
├── apps/
│   ├── frontend/
│   │   ├── claude-chat/          # React chat interface
│   │   └── secondary-ui/         # Admin dashboard
│   └── backend/
│       ├── java-service/         # Spring Boot microservice
│       ├── go-service/           # Go Gin microservice
│       └── python-service/       # FastAPI microservice
├── infrastructure/
│   ├── kubernetes/
│   │   ├── base/                 # Base K8s manifests
│   │   ├── istio/                # Istio configurations
│   │   └── minikube/             # Minikube configs
│   └── helm/                     # Helm charts
├── operations/
│   ├── monitoring/               # Prometheus, Grafana
│   ├── logging/                  # Logging stack
│   ├── ci-cd/                    # CI/CD workflows
│   └── scripts/                  # Utility scripts
├── database/
│   ├── migrations/               # DB migrations
│   └── seeds/                    # Seed data
├── shared/
│   ├── proto/                    # gRPC definitions
│   ├── libraries/                # Shared code
│   └── configs/                  # Shared configs
├── docs/                         # Documentation
└── tools/                        # Dev tools
```

## Prerequisites

- Docker (20.10+)
- Minikube (1.30+)
- kubectl (1.27+)
- Helm (3.12+)
- Node.js (18+) for frontend services
- Java 17+ for Java service
- Go 1.21+ for Go service
- Python 3.11+ for Python service

## Quick Start

### 1. Environment Setup

Install all prerequisites:

```bash
# Run the automated setup script
./operations/scripts/setup-environment.sh
```

This script will install:
- Docker
- Minikube
- kubectl
- Helm
- Istio CLI

### 2. Start Minikube Cluster

```bash
# Start Minikube with recommended resources
./operations/scripts/start-minikube.sh
```

### 3. Install Istio

```bash
# Install Istio service mesh
./operations/scripts/install-istio.sh
```

### 4. Deploy Databases

```bash
# Deploy PostgreSQL, MySQL, and MongoDB
kubectl apply -f infrastructure/kubernetes/base/databases/
```

### 5. Build and Deploy Services

```bash
# Build all Docker images
./operations/scripts/build-all.sh

# Deploy all microservices
./operations/scripts/deploy-all.sh
```

### 6. Access the Application

```bash
# Get the Istio Gateway URL
./operations/scripts/get-gateway-url.sh

# Access the Claude Chat UI
# Navigate to: http://<GATEWAY_URL>/chat

# Access the Admin Dashboard
# Navigate to: http://<GATEWAY_URL>/admin
```

## Development Workflow

### Running Services Locally

Each service can be run locally for development:

```bash
# Frontend services
cd apps/frontend/claude-chat && npm install && npm start

# Backend services
cd apps/backend/python-service && python -m uvicorn main:app --reload
cd apps/backend/java-service && ./mvnw spring-boot:run
cd apps/backend/go-service && go run main.go
```

### Building Docker Images

```bash
# Build specific service
./operations/scripts/build-service.sh java-service

# Build all services
./operations/scripts/build-all.sh
```

### Deploying to Minikube

```bash
# Deploy specific service
kubectl apply -f infrastructure/kubernetes/base/java-service/

# Deploy all services
./operations/scripts/deploy-all.sh
```

### Accessing Services

```bash
# Port-forward to specific service
kubectl port-forward svc/java-service 8080:8080

# Access via Istio Gateway
# Services are exposed through Istio Gateway at configured paths
```

## Service Details

### Java Service (Port 8080)
- **Framework**: Spring Boot 3.x
- **Database**: PostgreSQL
- **API**: REST + gRPC
- **Endpoints**: `/api/java/*`

### Go Service (Port 8081)
- **Framework**: Gin
- **Database**: MySQL
- **API**: REST
- **Endpoints**: `/api/go/*`

### Python Service (Port 8082)
- **Framework**: FastAPI
- **Database**: MongoDB
- **API**: REST
- **Endpoints**: `/api/python/*`

### Claude Chat UI (Port 3000)
- **Framework**: React 18 + TypeScript
- **Features**: Real-time chat, WebSocket support
- **Path**: `/chat`

### Secondary UI (Port 3001)
- **Framework**: React 18 + TypeScript
- **Features**: Admin dashboard, metrics visualization
- **Path**: `/admin`

## Observability

### Metrics
Access Grafana dashboard:
```bash
kubectl port-forward -n istio-system svc/grafana 3000:3000
# Visit: http://localhost:3000
```

### Tracing
Access Jaeger UI:
```bash
kubectl port-forward -n istio-system svc/tracing 16686:16686
# Visit: http://localhost:16686
```

### Service Mesh Visualization
Access Kiali:
```bash
kubectl port-forward -n istio-system svc/kiali 20001:20001
# Visit: http://localhost:20001
```

## Testing

### Unit Tests
```bash
# Run tests for all services
./operations/scripts/run-tests.sh

# Run tests for specific service
cd apps/backend/python-service && pytest
cd apps/backend/java-service && ./mvnw test
cd apps/backend/go-service && go test ./...
```

### Integration Tests
```bash
# Run integration tests
./operations/scripts/run-integration-tests.sh
```

### Load Tests
```bash
# Run load tests with k6
./operations/scripts/run-load-tests.sh
```

## Database Management

### Migrations
```bash
# Run PostgreSQL migrations
./operations/scripts/migrate.sh postgresql

# Run MySQL migrations
./operations/scripts/migrate.sh mysql

# Run MongoDB migrations
./operations/scripts/migrate.sh mongodb
```

### Seed Data
```bash
# Load seed data
./operations/scripts/seed-databases.sh
```

## Troubleshooting

### Check Service Health
```bash
# Check all pods
kubectl get pods -A

# Check Istio sidecars
kubectl get pods -o jsonpath='{.items[*].spec.containers[*].name}' | grep istio-proxy

# Check service logs
kubectl logs -f <pod-name> -c <container-name>
```

### Common Issues

1. **Minikube won't start**
   ```bash
   minikube delete && minikube start --memory=8192 --cpus=4
   ```

2. **Istio sidecars not injecting**
   ```bash
   kubectl label namespace default istio-injection=enabled
   ```

3. **Services can't connect**
   ```bash
   # Check Istio configuration
   istioctl analyze
   ```

## CI/CD

GitHub Actions workflows are configured in `.github/workflows/`:
- `build.yml` - Build and test all services
- `deploy-dev.yml` - Deploy to development environment
- `integration-tests.yml` - Run integration tests

## Documentation

- [Architecture Overview](docs/architecture/overview.md)
- [API Documentation](docs/api/README.md)
- [Deployment Guide](docs/runbooks/deployment.md)
- [Troubleshooting Guide](docs/runbooks/troubleshooting.md)
- [Development Guide](docs/runbooks/development.md)

## Contributing

1. Create a feature branch
2. Make changes and add tests
3. Ensure all tests pass
4. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

For issues and questions:
- Create an issue in the GitHub repository
- Check the [troubleshooting guide](docs/runbooks/troubleshooting.md)
- Review [documentation](docs/)



---


Create root-level monorepo directory structure

Create backend service boilerplate (Java, Go, Python)

Create frontend service boilerplate (React apps)

Create Dockerfiles for all services

Create Kubernetes base manifests for all services

Create Istio configurations (Gateway, VirtualServices)

Create database manifests and configurations

Create setup scripts (Minikube, Docker, Istio installation)

Create deployment and utility scripts

Create monitoring configurations (Prometheus, Grafana)

Create documentation (README, architecture diagrams)

Create shared configurations and proto definitions
