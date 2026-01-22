# Everything Portal - Scripts Guide

Complete guide to all available scripts in the Everything Portal project.

## 🎯 Quick Reference

| Script | Purpose | Time | When to Use |
|--------|---------|------|-------------|
| **startup.sh** | Deploy everything | 45-60 min | First deployment or fresh start |
| **test-deployment.sh** | Test deployment | 1-2 min | Verify everything is working |
| Individual scripts | Specific tasks | Varies | Manual control or troubleshooting |

## 🚀 Master Scripts

### startup.sh - One-Command Deployment

**Purpose**: Automated end-to-end deployment of the entire platform.

**What it does**:
1. ✅ Checks prerequisites
2. ✅ Installs missing tools (Docker, kubectl, Minikube, Helm, Istio)
3. ✅ Starts Minikube cluster
4. ✅ Installs Istio service mesh
5. ✅ Builds all Docker images
6. ✅ Deploys all services and databases
7. ✅ Configures Istio routing
8. ✅ Tests health endpoints
9. ✅ Displays access URLs

**Usage**:
```bash
# Basic deployment (installs everything)
./startup.sh

# Clean start (delete everything first)
./startup.sh --clean

# Skip installation (if already installed)
./startup.sh --skip-install

# Skip building (use existing images)
./startup.sh --skip-build

# Combine options
./startup.sh --skip-install --skip-build

# Get help
./startup.sh --help
```

**Time**: 45-60 minutes (first run), 10-15 minutes (subsequent runs)

**Output**: Gateway URLs, service endpoints, observability tool commands

---

### test-deployment.sh - Deployment Verification

**Purpose**: Quickly verify your deployment is working correctly.

**What it tests**:
1. ✅ Prerequisites installed
2. ✅ Minikube running
3. ✅ Istio service mesh
4. ✅ Database pods
5. ✅ Backend services
6. ✅ Frontend services
7. ✅ Istio configuration
8. ✅ Gateway connectivity
9. ✅ Pod health

**Usage**:
```bash
# Run all tests
./test-deployment.sh
```

**Exit codes**:
- `0` - All tests passed
- `1` - Some tests failed

**Time**: 1-2 minutes

**Output**:
- Test results with ✓/✗/⚠ indicators
- Summary with passed/warning/failed counts
- Helpful commands for troubleshooting
- Access URLs

---

## 📦 Individual Scripts

Located in `operations/scripts/`

### setup-environment.sh

**Purpose**: Install all prerequisites (Docker, kubectl, Minikube, Helm, Istio CLI)

**Usage**:
```bash
./operations/scripts/setup-environment.sh
```

**What it installs**:
- Docker (if not present)
- kubectl (Kubernetes CLI)
- Minikube (local K8s cluster)
- Helm (package manager)
- istioctl (Istio CLI)

**Time**: 5-10 minutes

**Platform support**: Linux, macOS

---

### start-minikube.sh

**Purpose**: Start Minikube with appropriate configuration

**Usage**:
```bash
./operations/scripts/start-minikube.sh
```

**Configuration**:
- Memory: 8GB (8192 MB)
- CPUs: 4 cores
- Driver: docker
- Kubernetes: v1.28.0
- Addons: metrics-server, dashboard

**Time**: 2-3 minutes

**Note**: Adjust resources if needed by editing the script

---

### install-istio.sh

**Purpose**: Install Istio service mesh with full observability stack

**Usage**:
```bash
./operations/scripts/install-istio.sh
```

**What it installs**:
- Istio control plane (istiod)
- Istio Ingress Gateway
- Istio Egress Gateway
- Prometheus (metrics)
- Grafana (dashboards)
- Jaeger (tracing)
- Kiali (service mesh visualization)

**Time**: 3-5 minutes

**Profile**: demo (includes all observability tools)

---

### build-all.sh

**Purpose**: Build Docker images for all services

**Usage**:
```bash
# First, configure Docker to use Minikube's daemon
eval $(minikube docker-env)

# Then build
./operations/scripts/build-all.sh
```

**Builds**:
1. python-service:latest
2. go-service:latest
3. java-service:latest (slowest, ~5-7 minutes)
4. claude-chat:latest
5. secondary-ui:latest

**Time**: 10-15 minutes total

**Note**: Java service takes longest due to Maven dependencies

---

### deploy-all.sh

**Purpose**: Deploy all services to Kubernetes

**Usage**:
```bash
./operations/scripts/deploy-all.sh
```

**Deployment order**:
1. Database secrets and ConfigMaps
2. Databases (PostgreSQL, MySQL, MongoDB)
3. Backend services (Java, Go, Python)
4. Frontend services (Claude Chat, Admin)
5. Istio Gateway
6. Istio VirtualServices
7. Istio DestinationRules

**Time**: 5-10 minutes (includes waiting for databases)

**Verification**: Script shows pod status and gateway URL

---

### get-gateway-url.sh

**Purpose**: Display Istio Gateway access URLs

**Usage**:
```bash
./operations/scripts/get-gateway-url.sh
```

**Output**:
- Gateway base URL
- Claude Chat URL
- Admin Dashboard URL
- Backend service health endpoints
- Test commands

**Time**: Instant

---

### cleanup.sh

**Purpose**: Remove all deployed resources (keeps Minikube running)

**Usage**:
```bash
./operations/scripts/cleanup.sh
```

**What it deletes**:
- All deployments
- All services
- All statefulsets
- Istio Gateway and VirtualServices
- Persistent Volume Claims

**Time**: 1-2 minutes

**Note**: Requires confirmation before proceeding

---

### view-logs.sh

**Purpose**: View logs for a specific service

**Usage**:
```bash
./operations/scripts/view-logs.sh <service-name>

# Examples:
./operations/scripts/view-logs.sh python-service
./operations/scripts/view-logs.sh go-service
./operations/scripts/view-logs.sh java-service
./operations/scripts/view-logs.sh postgresql
./operations/scripts/view-logs.sh mysql
./operations/scripts/view-logs.sh mongodb
```

**Features**:
- Follows logs in real-time (`-f` flag)
- Shows service name and pod name
- Press Ctrl+C to exit

**Time**: Continuous (until stopped)

---

## 🎯 Common Workflows

### First-Time Setup
```bash
# One command
./startup.sh

# Or step by step
./operations/scripts/setup-environment.sh
./operations/scripts/start-minikube.sh
./operations/scripts/install-istio.sh
eval $(minikube docker-env)
./operations/scripts/build-all.sh
./operations/scripts/deploy-all.sh
```

### Fresh Start (Clean Everything)
```bash
./startup.sh --clean
```

### Quick Redeploy (After Code Changes)
```bash
# Rebuild images
eval $(minikube docker-env)
./operations/scripts/build-all.sh

# Redeploy
./operations/scripts/deploy-all.sh
```

### Rebuild Single Service
```bash
# Configure Docker
eval $(minikube docker-env)

# Build
docker build -t python-service:latest apps/backend/python-service

# Restart
kubectl rollout restart deployment python-service
kubectl rollout status deployment python-service
```

### Verify Deployment
```bash
./test-deployment.sh
```

### Check Logs
```bash
# View specific service
./operations/scripts/view-logs.sh python-service

# Or use kubectl directly
kubectl logs -f deployment/python-service
```

### Get Access URLs
```bash
./operations/scripts/get-gateway-url.sh

# Or get from saved file
cat .gateway-url
```

### Complete Cleanup
```bash
# Remove deployments
./operations/scripts/cleanup.sh

# Stop Minikube
minikube stop

# Delete Minikube (complete removal)
minikube delete
```

---

## 🔧 Script Options Summary

### startup.sh
| Option | Description |
|--------|-------------|
| `--skip-install` | Skip prerequisite installation |
| `--skip-build` | Skip Docker image building |
| `--clean` | Delete everything and start fresh |
| `--help` | Show help message |

### All Other Scripts
- No options required
- Run as-is
- Check script contents for details

---

## 📊 Time Estimates

| Task | Time | Script |
|------|------|--------|
| Full deployment (first time) | 45-60 min | `./startup.sh` |
| Full deployment (subsequent) | 10-15 min | `./startup.sh --skip-install` |
| Prerequisites only | 5-10 min | `./operations/scripts/setup-environment.sh` |
| Minikube start | 2-3 min | `./operations/scripts/start-minikube.sh` |
| Istio install | 3-5 min | `./operations/scripts/install-istio.sh` |
| Build images | 10-15 min | `./operations/scripts/build-all.sh` |
| Deploy services | 5-10 min | `./operations/scripts/deploy-all.sh` |
| Test deployment | 1-2 min | `./test-deployment.sh` |
| View logs | Continuous | `./operations/scripts/view-logs.sh <service>` |
| Cleanup | 1-2 min | `./operations/scripts/cleanup.sh` |

---

## 🆘 Troubleshooting

### Script Fails with Error

**Check**:
1. Read error message carefully
2. Check prerequisites: `./test-deployment.sh`
3. Check Minikube status: `minikube status`
4. Check pod status: `kubectl get pods`

**Solutions**:
- Re-run individual scripts to isolate issue
- Check detailed guide: [docs/runbooks/troubleshooting.md](docs/runbooks/troubleshooting.md)

### Docker Images Not Found

**Solution**:
```bash
# Ensure using Minikube's Docker daemon
eval $(minikube docker-env)

# Verify images exist
docker images | grep -E "(python|go|java|claude|secondary)"

# Rebuild if missing
./operations/scripts/build-all.sh
```

### Services Not Starting

**Check logs**:
```bash
./operations/scripts/view-logs.sh <service-name>
```

**Common issues**:
- Database not ready: Wait 2-3 minutes
- Insufficient resources: Increase Minikube resources
- Image pull issues: Check `imagePullPolicy` is `IfNotPresent`

### Minikube Issues

**Reset Minikube**:
```bash
minikube stop
minikube delete
minikube start --memory=8192 --cpus=4
```

---

## 📚 Additional Resources

- **[QUICKSTART.md](QUICKSTART.md)** - Quick start guide
- **[GETTING_STARTED.md](GETTING_STARTED.md)** - Detailed setup guide
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Complete project overview
- **[docs/runbooks/deployment.md](docs/runbooks/deployment.md)** - Deployment runbook
- **[docs/runbooks/troubleshooting.md](docs/runbooks/troubleshooting.md)** - Troubleshooting guide

---

## 💡 Tips

1. **Save time**: Use `./startup.sh --skip-install` after first run
2. **Quick test**: Run `./test-deployment.sh` to verify health
3. **View everything**: Use `watch kubectl get pods` to monitor status
4. **Save URLs**: Gateway URL is auto-saved to `.gateway-url`
5. **Clean slate**: Use `./startup.sh --clean` for troubleshooting

---

**Made a script better? Consider contributing back!** 🚀
