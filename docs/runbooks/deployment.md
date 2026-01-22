# Deployment Guide

Complete step-by-step guide for deploying Everything Portal from scratch.

## Prerequisites

- macOS or Linux machine
- Minimum 8GB RAM
- 20GB free disk space
- Internet connection

## Step 1: Install Prerequisites

Run the environment setup script:

```bash
chmod +x operations/scripts/setup-environment.sh
./operations/scripts/setup-environment.sh
```

This will install:
- Docker
- kubectl
- Minikube
- Helm
- istioctl

### Manual Installation (if needed)

**Docker**:
```bash
# Linux
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# macOS
# Download from https://www.docker.com/products/docker-desktop
```

**kubectl**:
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/$(uname -s | tr '[:upper:]' '[:lower:]')/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

**Minikube**:
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-$(uname -s | tr '[:upper:]' '[:lower:]')-amd64
sudo install minikube-* /usr/local/bin/minikube
```

## Step 2: Start Minikube

```bash
chmod +x operations/scripts/start-minikube.sh
./operations/scripts/start-minikube.sh
```

This starts Minikube with:
- 8GB RAM
- 4 CPUs
- metrics-server addon
- dashboard addon

Verify Minikube is running:
```bash
minikube status
kubectl cluster-info
```

## Step 3: Install Istio

```bash
chmod +x operations/scripts/install-istio.sh
./operations/scripts/install-istio.sh
```

This installs:
- Istio control plane (istiod)
- Istio Ingress Gateway
- Prometheus
- Grafana
- Jaeger
- Kiali

Verify Istio installation:
```bash
kubectl get pods -n istio-system
istioctl verify-install
```

## Step 4: Configure Docker Environment

Configure your shell to use Minikube's Docker daemon:

```bash
eval $(minikube docker-env)
```

This allows you to build images directly in Minikube without pushing to a registry.

## Step 5: Build Docker Images

Build all service images:

```bash
chmod +x operations/scripts/build-all.sh
./operations/scripts/build-all.sh
```

This builds:
1. Python Service
2. Go Service
3. Java Service
4. Claude Chat Frontend
5. Admin Dashboard

Verify images:
```bash
docker images | grep -E "(python-service|go-service|java-service|claude-chat|secondary-ui)"
```

## Step 6: Deploy Services

Deploy all services to Kubernetes:

```bash
chmod +x operations/scripts/deploy-all.sh
./operations/scripts/deploy-all.sh
```

Deployment order:
1. Database secrets and ConfigMaps
2. Databases (PostgreSQL, MySQL, MongoDB)
3. Backend services (Java, Go, Python)
4. Frontend services (Claude Chat, Admin Dashboard)
5. Istio Gateway and VirtualServices
6. Istio DestinationRules and policies

## Step 7: Verify Deployment

Check all pods are running:
```bash
kubectl get pods
```

Expected output:
```
NAME                               READY   STATUS    RESTARTS   AGE
claude-chat-xxx                    2/2     Running   0          2m
go-service-xxx                     2/2     Running   0          3m
java-service-xxx                   2/2     Running   0          3m
mongodb-0                          1/1     Running   0          5m
mysql-0                            1/1     Running   0          5m
postgresql-0                       1/1     Running   0          5m
python-service-xxx                 2/2     Running   0          3m
secondary-ui-xxx                   2/2     Running   0          2m
```

Note: `2/2` indicates the service container + Istio sidecar are both running.

Check services:
```bash
kubectl get svc
```

Check Istio Gateway:
```bash
kubectl get gateway
kubectl get virtualservice
```

## Step 8: Access the Application

Get the Gateway URL:
```bash
chmod +x operations/scripts/get-gateway-url.sh
./operations/scripts/get-gateway-url.sh
```

This outputs:
- Claude Chat URL
- Admin Dashboard URL
- API endpoint URLs

Example:
```
Istio Gateway URL: http://192.168.49.2:30080

Service Endpoints:
  - Claude Chat:    http://192.168.49.2:30080/chat
  - Admin Dashboard: http://192.168.49.2:30080/admin
  - Java Service:   http://192.168.49.2:30080/api/java/health
  - Go Service:     http://192.168.49.2:30080/api/go/health
  - Python Service: http://192.168.49.2:30080/api/python/health
```

## Step 9: Test the Services

Test health endpoints:
```bash
GATEWAY_URL=$(minikube ip):$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')

# Test Python Service
curl http://${GATEWAY_URL}/api/python/health

# Test Go Service
curl http://${GATEWAY_URL}/api/go/health

# Test Java Service
curl http://${GATEWAY_URL}/api/java/health
```

Open in browser:
```bash
# Claude Chat
open http://${GATEWAY_URL}/chat

# Admin Dashboard
open http://${GATEWAY_URL}/admin
```

## Step 10: Access Observability Tools

### Kiali (Service Mesh)
```bash
kubectl port-forward -n istio-system svc/kiali 20001:20001
open http://localhost:20001
```

### Grafana (Dashboards)
```bash
kubectl port-forward -n istio-system svc/grafana 3000:3000
open http://localhost:3000
```

### Jaeger (Tracing)
```bash
kubectl port-forward -n istio-system svc/tracing 16686:16686
open http://localhost:16686
```

### Prometheus (Metrics)
```bash
kubectl port-forward -n istio-system svc/prometheus 9090:9090
open http://localhost:9090
```

## Common Deployment Issues

### Issue: Pods stuck in Pending state
**Cause**: Insufficient resources

**Solution**:
```bash
# Increase Minikube resources
minikube stop
minikube start --memory=10240 --cpus=6
```

### Issue: ImagePullBackOff error
**Cause**: Image not found in Minikube's Docker

**Solution**:
```bash
# Ensure you're using Minikube's Docker daemon
eval $(minikube docker-env)

# Rebuild images
./operations/scripts/build-all.sh
```

### Issue: Database pods not ready
**Cause**: Database initialization takes time

**Solution**:
```bash
# Wait longer or check logs
kubectl logs -f postgresql-0
kubectl logs -f mysql-0
kubectl logs -f mongodb-0
```

### Issue: Services not accessible through Gateway
**Cause**: Istio Gateway or VirtualService misconfiguration

**Solution**:
```bash
# Check Istio configuration
istioctl analyze

# Verify Gateway
kubectl get gateway
kubectl describe gateway everything-portal-gateway

# Verify VirtualServices
kubectl get virtualservice
```

### Issue: Istio sidecar not injected
**Cause**: Namespace not labeled for injection

**Solution**:
```bash
kubectl label namespace default istio-injection=enabled --overwrite
# Restart deployments
kubectl rollout restart deployment --all
```

## Updating Services

### Update a single service:
```bash
# 1. Make code changes
# 2. Rebuild image
eval $(minikube docker-env)
docker build -t python-service:latest apps/backend/python-service

# 3. Restart deployment
kubectl rollout restart deployment python-service

# 4. Watch rollout
kubectl rollout status deployment python-service
```

### Update all services:
```bash
./operations/scripts/build-all.sh
kubectl rollout restart deployment --all
```

## Cleanup

### Remove all deployments but keep Minikube:
```bash
./operations/scripts/cleanup.sh
```

### Stop Minikube:
```bash
minikube stop
```

### Delete Minikube (complete cleanup):
```bash
minikube delete
```

## Production Deployment Checklist

- [ ] Use production-grade Kubernetes cluster (GKE, EKS, AKS)
- [ ] Set up managed databases instead of in-cluster
- [ ] Configure proper Ingress with TLS certificates
- [ ] Use proper secret management (Vault, Sealed Secrets)
- [ ] Enable STRICT mTLS in Istio
- [ ] Set up CI/CD pipelines
- [ ] Configure horizontal pod autoscaling
- [ ] Set up backup and disaster recovery
- [ ] Configure monitoring alerts
- [ ] Implement log aggregation
- [ ] Security scan all images
- [ ] Set up network policies
- [ ] Configure resource quotas
- [ ] Document runbooks
- [ ] Set up on-call rotation
