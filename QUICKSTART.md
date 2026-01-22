# Quick Start Guide

Deploy Everything Portal in **one command**!

## Prerequisites

You need **Docker Desktop** installed (for WSL2 or native Linux/Mac).

### For WSL2 Users:
1. Install [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop)
2. Enable WSL 2 integration in Docker Desktop settings
3. Verify: `docker --version`

### For Linux/Mac Users:
Docker will be installed automatically by the startup script.

## One-Command Deployment

```bash
./startup.sh
```

That's it! The script will:
- ✅ Install prerequisites (kubectl, minikube, helm, istioctl)
- ✅ Start Minikube cluster
- ✅ Install Istio service mesh
- ✅ Build all Docker images
- ✅ Deploy 5 microservices
- ✅ Deploy 3 databases
- ✅ Configure service mesh
- ✅ Test health checks
- ✅ Show access URLs

**Time**: 45-60 minutes (first run)

## Advanced Options

### Clean Start (Delete Everything First)
```bash
./startup.sh --clean
```

### Skip Installation (If Already Installed)
```bash
./startup.sh --skip-install
```

### Skip Building (Use Existing Images)
```bash
./startup.sh --skip-build
```

### Combine Options
```bash
./startup.sh --skip-install --skip-build
```

### Get Help
```bash
./startup.sh --help
```

## What You Get

After the script completes, you'll have:

### Frontend Services
- **Claude Chat**: `http://<GATEWAY_URL>/chat`
- **Admin Dashboard**: `http://<GATEWAY_URL>/admin`

### Backend Services
- **Java Service**: `http://<GATEWAY_URL>/api/java/health`
- **Go Service**: `http://<GATEWAY_URL>/api/go/health`
- **Python Service**: `http://<GATEWAY_URL>/api/python/health`

### Observability Tools
- **Kiali** (Service Mesh): Port-forward on 20001
- **Grafana** (Dashboards): Port-forward on 3000
- **Jaeger** (Tracing): Port-forward on 16686
- **Prometheus** (Metrics): Port-forward on 9090

## Checking Status

```bash
# View all pods
kubectl get pods

# View services
kubectl get svc

# Get Gateway URL
cat .gateway-url
# or
./operations/scripts/get-gateway-url.sh

# View logs
./operations/scripts/view-logs.sh python-service
```

## Testing the Deployment

```bash
# Get the gateway URL
GATEWAY_URL=$(cat .gateway-url)

# Test health endpoints
curl $GATEWAY_URL/api/python/health
curl $GATEWAY_URL/api/go/health
curl $GATEWAY_URL/api/java/health

# Create test data
curl -X POST $GATEWAY_URL/api/python/data \
  -H "Content-Type: application/json" \
  -d '{"name": "test", "value": 42.0}'

# Open in browser
open $GATEWAY_URL/chat        # macOS
xdg-open $GATEWAY_URL/chat    # Linux
```

## Accessing Observability Tools

### Kiali (Service Mesh Visualization)
```bash
kubectl port-forward -n istio-system svc/kiali 20001:20001
# Open: http://localhost:20001
```

### Grafana (Metrics Dashboards)
```bash
kubectl port-forward -n istio-system svc/grafana 3000:3000
# Open: http://localhost:3000
```

### Jaeger (Distributed Tracing)
```bash
kubectl port-forward -n istio-system svc/tracing 16686:16686
# Open: http://localhost:16686
```

### Prometheus (Metrics)
```bash
kubectl port-forward -n istio-system svc/prometheus 9090:9090
# Open: http://localhost:9090
```

## Troubleshooting

### Script Fails
```bash
# Check the error message and run individual steps:
./operations/scripts/setup-environment.sh
./operations/scripts/start-minikube.sh
./operations/scripts/install-istio.sh
```

### Pods Not Starting
```bash
# Check pod status
kubectl get pods

# Check specific pod logs
kubectl logs -f <pod-name>

# Describe pod for events
kubectl describe pod <pod-name>
```

### Services Not Accessible
```bash
# Verify Istio Gateway
kubectl get gateway
kubectl get virtualservice

# Check Istio ingress gateway
kubectl get svc -n istio-system istio-ingressgateway
```

### Need More Resources
```bash
# Stop Minikube
minikube stop

# Start with more resources
minikube start --memory=10240 --cpus=6
```

## Cleanup

### Remove Deployments (Keep Minikube)
```bash
./operations/scripts/cleanup.sh
```

### Stop Minikube
```bash
minikube stop
```

### Delete Everything
```bash
minikube delete
```

### Fresh Start
```bash
./startup.sh --clean
```

## Next Steps

1. **Explore the Code**: Browse `apps/` directory
2. **Read Documentation**: Check `docs/` directory
3. **Make Changes**: Edit services and redeploy
4. **Monitor**: Use observability tools
5. **Scale**: Try `kubectl scale deployment python-service --replicas=3`

## Common Commands

```bash
# View all resources
kubectl get all

# Watch pod status
watch kubectl get pods

# Get Gateway URL
./operations/scripts/get-gateway-url.sh

# View service logs
./operations/scripts/view-logs.sh <service-name>

# Rebuild and restart service
eval $(minikube docker-env)
docker build -t python-service:latest apps/backend/python-service
kubectl rollout restart deployment python-service

# Access Minikube dashboard
minikube dashboard
```

## Support

For detailed information, see:
- **[GETTING_STARTED.md](GETTING_STARTED.md)** - Detailed setup guide
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Complete project overview
- **[docs/runbooks/troubleshooting.md](docs/runbooks/troubleshooting.md)** - Troubleshooting guide
- **[docs/api/README.md](docs/api/README.md)** - API documentation

## Time Breakdown

| Step | Time | Description |
|------|------|-------------|
| Prerequisites | 10 min | Install Docker, kubectl, minikube, helm, istio |
| Minikube Start | 3 min | Start local Kubernetes cluster |
| Istio Install | 5 min | Install service mesh |
| Build Images | 15 min | Build all Docker images |
| Deploy Services | 10 min | Deploy to Kubernetes |
| Wait for Ready | 5 min | Wait for pods to start |
| **Total** | **~45-60 min** | **First-time deployment** |

Subsequent deployments: **~10 minutes**

---

**That's it! One command to rule them all! 🚀**

```bash
./startup.sh
```
