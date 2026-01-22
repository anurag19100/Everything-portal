# Getting Started with Everything Portal

Welcome to Everything Portal! This guide will help you get the entire microservices platform up and running.

## Quick Start (TL;DR)

```bash
# 1. Install prerequisites
./operations/scripts/setup-environment.sh

# 2. Start Minikube
./operations/scripts/start-minikube.sh

# 3. Install Istio
./operations/scripts/install-istio.sh

# 4. Configure Docker to use Minikube
eval $(minikube docker-env)

# 5. Build all services
./operations/scripts/build-all.sh

# 6. Deploy everything
./operations/scripts/deploy-all.sh

# 7. Get access URLs
./operations/scripts/get-gateway-url.sh
```

## What You'll Get

After following this guide, you'll have:

✅ **5 Microservices** running in Kubernetes:
- Java Service (Spring Boot + PostgreSQL)
- Go Service (Gin + MySQL)
- Python Service (FastAPI + MongoDB)
- Claude Chat UI (React)
- Admin Dashboard (React)

✅ **3 Databases**:
- PostgreSQL (for Java and Python services)
- MySQL (for Go service)
- MongoDB (for Python service)

✅ **Istio Service Mesh** with:
- API Gateway for external access
- Traffic management
- mTLS security
- Circuit breakers
- Load balancing

✅ **Observability Stack**:
- Prometheus (metrics)
- Grafana (dashboards)
- Jaeger (tracing)
- Kiali (service mesh visualization)

## Prerequisites

### System Requirements

- **OS**: Linux or macOS
- **RAM**: 8GB minimum (16GB recommended)
- **Disk**: 20GB free space
- **CPU**: 4 cores minimum

### Required Software

Will be installed by the setup script:
- Docker
- kubectl
- Minikube
- Helm
- istioctl

## Step-by-Step Guide

### Step 1: Clone and Navigate

```bash
cd /root/ws/Everything-portal
ls -la
```

You should see:
```
apps/               # All microservices
infrastructure/     # Kubernetes and Istio configs
operations/         # Scripts and monitoring
database/          # DB migrations and seeds
shared/            # Shared code and protos
docs/              # Documentation
```

### Step 2: Install Prerequisites

```bash
chmod +x operations/scripts/setup-environment.sh
./operations/scripts/setup-environment.sh
```

This script will:
- Check your operating system
- Install Docker (if not present)
- Install kubectl
- Install Minikube
- Install Helm
- Install Istio CLI

**Time**: 5-10 minutes

### Step 3: Start Minikube

```bash
./operations/scripts/start-minikube.sh
```

This creates a local Kubernetes cluster with:
- 8GB RAM allocation
- 4 CPU cores
- Metrics server enabled
- Dashboard enabled

**Verify**:
```bash
minikube status
kubectl get nodes
```

**Time**: 2-3 minutes

### Step 4: Install Istio Service Mesh

```bash
./operations/scripts/install-istio.sh
```

This installs:
- Istio control plane
- Ingress Gateway
- Observability tools (Prometheus, Grafana, Jaeger, Kiali)

**Verify**:
```bash
kubectl get pods -n istio-system
```

All pods should show `Running` status.

**Time**: 3-5 minutes

### Step 5: Configure Docker

Tell Docker to use Minikube's Docker daemon (so images are available in the cluster):

```bash
eval $(minikube docker-env)
```

**Important**: Run this in every new terminal session.

### Step 6: Build All Services

```bash
./operations/scripts/build-all.sh
```

This builds Docker images for:
1. Python Service (FastAPI)
2. Go Service (Gin)
3. Java Service (Spring Boot)
4. Claude Chat UI (React)
5. Admin Dashboard (React)

**Time**: 10-15 minutes (Java service is slowest)

**Verify**:
```bash
docker images
```

You should see:
- `python-service:latest`
- `go-service:latest`
- `java-service:latest`
- `claude-chat:latest`
- `secondary-ui:latest`

### Step 7: Deploy Everything

```bash
./operations/scripts/deploy-all.sh
```

This deploys in order:
1. Database secrets and configs
2. Databases (PostgreSQL, MySQL, MongoDB)
3. Backend services
4. Frontend services
5. Istio Gateway and routing rules

**Time**: 5-10 minutes (databases take longest to initialize)

**Watch deployment**:
```bash
watch kubectl get pods
```

Wait until all pods show `2/2` (service + sidecar) and `Running`.

### Step 8: Access the Application

Get your access URLs:

```bash
./operations/scripts/get-gateway-url.sh
```

You'll see something like:
```
Istio Gateway URL: http://192.168.49.2:30080

Service Endpoints:
  - Claude Chat:    http://192.168.49.2:30080/chat
  - Admin Dashboard: http://192.168.49.2:30080/admin
  - Java Service:   http://192.168.49.2:30080/api/java/health
  - Go Service:     http://192.168.49.2:30080/api/go/health
  - Python Service: http://192.168.49.2:30080/api/python/health
```

**Test services**:
```bash
GATEWAY_URL=http://192.168.49.2:30080

# Test health endpoints
curl $GATEWAY_URL/api/python/health
curl $GATEWAY_URL/api/go/health
curl $GATEWAY_URL/api/java/health
```

**Open in browser**:
- Claude Chat: `http://<GATEWAY_URL>/chat`
- Admin Dashboard: `http://<GATEWAY_URL>/admin`

## Access Observability Tools

### Kiali (Service Mesh Dashboard)
```bash
kubectl port-forward -n istio-system svc/kiali 20001:20001
open http://localhost:20001
```

Shows service graph, traffic flow, and mesh configuration.

### Grafana (Metrics Dashboards)
```bash
kubectl port-forward -n istio-system svc/grafana 3000:3000
open http://localhost:3000
```

Pre-built dashboards for Istio metrics.

### Jaeger (Distributed Tracing)
```bash
kubectl port-forward -n istio-system svc/tracing 16686:16686
open http://localhost:16686
```

Trace requests across services.

### Prometheus (Metrics Database)
```bash
kubectl port-forward -n istio-system svc/prometheus 9090:9090
open http://localhost:9090
```

Query metrics directly.

## Verify Everything Works

### 1. Check All Pods
```bash
kubectl get pods
```

All should show `2/2 Running`.

### 2. Check Services
```bash
kubectl get svc
```

### 3. Check Istio Gateway
```bash
kubectl get gateway
kubectl get virtualservice
```

### 4. Test API Calls
```bash
# Create a data item
curl -X POST $GATEWAY_URL/api/python/data \
  -H "Content-Type: application/json" \
  -d '{"name": "test", "value": 42.0}'

# Get items
curl $GATEWAY_URL/api/go/items

# Get products
curl $GATEWAY_URL/api/java/products
```

## Common Issues & Solutions

### Issue: Pods stuck in "Pending"
**Solution**: Increase Minikube resources
```bash
minikube stop
minikube start --memory=10240 --cpus=6
```

### Issue: ImagePullBackOff
**Solution**: Rebuild images with Minikube's Docker
```bash
eval $(minikube docker-env)
./operations/scripts/build-all.sh
```

### Issue: Services not accessible
**Solution**: Check Istio Gateway and VirtualServices
```bash
istioctl analyze
kubectl get gateway
kubectl get virtualservice
```

### Issue: Database pods failing
**Solution**: Check logs and restart
```bash
kubectl logs -f postgresql-0
kubectl delete pod postgresql-0  # Will auto-recreate
```

## Next Steps

Now that everything is running:

1. **Explore the Code**
   - Backend: `apps/backend/`
   - Frontend: `apps/frontend/`

2. **Read the Documentation**
   - Architecture: `docs/architecture/overview.md`
   - API Docs: `docs/api/README.md`
   - Troubleshooting: `docs/runbooks/troubleshooting.md`

3. **Make Changes**
   - Edit service code
   - Rebuild: `docker build -t service-name:latest .`
   - Restart: `kubectl rollout restart deployment service-name`

4. **Monitor Your Services**
   - Use Kiali to visualize traffic
   - Check Grafana dashboards
   - Trace requests in Jaeger

5. **Experiment**
   - Scale services: `kubectl scale deployment python-service --replicas=3`
   - Test circuit breakers
   - Try canary deployments

## Useful Commands

```bash
# View logs
./operations/scripts/view-logs.sh python-service

# Get Gateway URL
./operations/scripts/get-gateway-url.sh

# Rebuild and redeploy one service
eval $(minikube docker-env)
docker build -t python-service:latest apps/backend/python-service
kubectl rollout restart deployment python-service

# Clean up everything
./operations/scripts/cleanup.sh

# Stop Minikube
minikube stop

# Delete everything
minikube delete
```

## Getting Help

- **Documentation**: See `docs/` directory
- **Troubleshooting**: See `docs/runbooks/troubleshooting.md`
- **API Reference**: See `docs/api/README.md`
- **Architecture**: See `docs/architecture/overview.md`

## Clean Up

When you're done:

```bash
# Delete all deployments but keep Minikube
./operations/scripts/cleanup.sh

# Stop Minikube
minikube stop

# Delete Minikube completely
minikube delete
```

---

**Congratulations! 🎉** You now have a full production-ready microservices platform running locally!
