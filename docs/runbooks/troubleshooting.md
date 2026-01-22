# Troubleshooting Guide

Common issues and their solutions.

## Service Health Issues

### Pod CrashLoopBackOff

**Symptoms**: Pod keeps restarting
```bash
kubectl get pods
# Shows: CrashLoopBackOff
```

**Diagnosis**:
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl logs <pod-name> --previous  # Last run logs
```

**Common Causes**:
1. **Application error**: Check logs for stack traces
2. **Missing dependencies**: Check ConfigMaps/Secrets exist
3. **Database connection failure**: Verify database pods are running
4. **Resource limits**: Pod OOMKilled - increase memory limits

**Solutions**:
```bash
# Check database connectivity
kubectl exec -it <pod-name> -- ping postgresql

# Increase resources in deployment YAML
resources:
  limits:
    memory: "1Gi"  # Increase from 512Mi

# Apply changes
kubectl apply -f infrastructure/kubernetes/base/<service>/deployment.yaml
```

### Liveness/Readiness Probe Failures

**Symptoms**: Pod marked as not ready

**Diagnosis**:
```bash
kubectl describe pod <pod-name>
# Look for: Liveness probe failed / Readiness probe failed
```

**Solutions**:
```bash
# Test health endpoint manually
kubectl exec -it <pod-name> -- curl localhost:8080/health

# Increase probe timeouts in deployment
livenessProbe:
  initialDelaySeconds: 60  # Increase if slow startup
  timeoutSeconds: 5        # Increase if endpoint is slow
```

## Network Issues

### Services Can't Communicate

**Symptoms**: Service A can't reach Service B

**Diagnosis**:
```bash
# Test service connectivity
kubectl exec -it <pod-a> -- curl http://service-b:8080/health

# Check service endpoints
kubectl get endpoints

# Check Istio configuration
istioctl analyze
```

**Common Causes**:
1. Service not registered
2. Wrong port in service definition
3. Istio VirtualService misconfiguration
4. Network policy blocking traffic

**Solutions**:
```bash
# Verify service exists
kubectl get svc service-b

# Check service selectors match pod labels
kubectl get pods --show-labels
kubectl describe svc service-b

# Test without Istio sidecar
kubectl exec -it <pod-a> -c <main-container> -- curl http://service-b:8080
```

### Gateway Not Accessible

**Symptoms**: Cannot access services through Istio Gateway

**Diagnosis**:
```bash
# Get Gateway status
kubectl get gateway
kubectl describe gateway everything-portal-gateway

# Check Ingress Gateway pod
kubectl get pods -n istio-system | grep ingressgateway

# Get Gateway URL
minikube ip
kubectl -n istio-system get svc istio-ingressgateway
```

**Solutions**:
```bash
# Verify VirtualService routing
kubectl get virtualservice
kubectl describe virtualservice python-service-vs

# Test Gateway directly
GATEWAY_URL=$(minikube ip):$(kubectl -n istio-system get svc istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
curl -v http://${GATEWAY_URL}/api/python/health

# Check Istio proxy logs
kubectl logs -n istio-system <ingressgateway-pod>
```

## Database Issues

### PostgreSQL Connection Failed

**Diagnosis**:
```bash
kubectl logs -f <service-pod>
# Look for: "connection refused" or "authentication failed"

# Check PostgreSQL pod
kubectl get pods | grep postgresql
kubectl logs -f postgresql-0
```

**Solutions**:
```bash
# Test database connectivity
kubectl exec -it postgresql-0 -- psql -U postgres -c "SELECT 1"

# Check secret exists
kubectl get secret postgres-secret
kubectl get secret postgres-secret -o yaml

# Verify environment variables
kubectl describe pod <service-pod> | grep -A 10 "Environment:"

# Reset database pod
kubectl delete pod postgresql-0
```

### MySQL Connection Issues

**Diagnosis**:
```bash
kubectl logs -f go-service-xxx
# Look for MySQL error codes

kubectl logs -f mysql-0
```

**Solutions**:
```bash
# Test MySQL connection
kubectl exec -it mysql-0 -- mysql -u root -p -e "SHOW DATABASES;"

# Check permissions
kubectl exec -it mysql-0 -- mysql -u root -p -e "SHOW GRANTS FOR 'root'@'%';"

# Reset MySQL root password if needed
kubectl delete secret mysql-secret
# Recreate with correct password
kubectl create secret generic mysql-secret --from-literal=password=newpassword
kubectl delete pod mysql-0
```

### MongoDB Connection Issues

**Diagnosis**:
```bash
kubectl logs -f python-service-xxx
kubectl logs -f mongodb-0
```

**Solutions**:
```bash
# Test MongoDB connection
kubectl exec -it mongodb-0 -- mongosh --eval "db.adminCommand('ping')"

# Check database exists
kubectl exec -it mongodb-0 -- mongosh --eval "show dbs"

# Recreate MongoDB pod
kubectl delete pod mongodb-0
```

## Istio Issues

### Sidecar Not Injected

**Symptoms**: Pods show 1/1 instead of 2/2

**Diagnosis**:
```bash
kubectl get pods
# Should show 2/2 (app + istio-proxy)

kubectl get namespace default --show-labels
# Should have: istio-injection=enabled
```

**Solutions**:
```bash
# Enable sidecar injection
kubectl label namespace default istio-injection=enabled --overwrite

# Restart deployments
kubectl rollout restart deployment --all

# Manually inject for specific deployment
kubectl get deployment <deployment-name> -o yaml | istioctl kube-inject -f - | kubectl apply -f -
```

### mTLS Issues

**Symptoms**: Services can't communicate with TLS errors

**Diagnosis**:
```bash
istioctl analyze

# Check PeerAuthentication
kubectl get peerauthentication

# Check mTLS status
istioctl authn tls-check <pod-name>
```

**Solutions**:
```bash
# Set to PERMISSIVE mode (allows both mTLS and plain text)
kubectl apply -f infrastructure/kubernetes/istio/peer-authentication.yaml

# Check DestinationRule mTLS settings
kubectl get destinationrule -o yaml
```

### Circuit Breaker Triggering

**Symptoms**: Requests failing with 503

**Diagnosis**:
```bash
# Check DestinationRule outlier detection
kubectl describe destinationrule <service>-dr

# Check Kiali for circuit breaker status
kubectl port-forward -n istio-system svc/kiali 20001:20001
```

**Solutions**:
```bash
# Adjust circuit breaker settings in DestinationRule
outlierDetection:
  consecutiveErrors: 10    # Increase threshold
  interval: 60s           # Increase detection interval
  baseEjectionTime: 60s   # Increase ejection time
```

## Performance Issues

### High Memory Usage

**Diagnosis**:
```bash
# Check pod memory
kubectl top pods

# Get detailed resource usage
kubectl describe node

# Check for OOMKilled pods
kubectl get pods -A | grep OOMKilled
```

**Solutions**:
```bash
# Increase memory limits
# Edit deployment YAML
resources:
  limits:
    memory: "1Gi"
  requests:
    memory: "512Mi"

# Apply changes
kubectl apply -f <deployment-file>

# Monitor memory usage
watch kubectl top pods
```

### High Latency

**Diagnosis**:
```bash
# Check service metrics in Grafana
kubectl port-forward -n istio-system svc/grafana 3000:3000

# View distributed traces in Jaeger
kubectl port-forward -n istio-system svc/tracing 16686:16686

# Check resource constraints
kubectl top pods
kubectl top nodes
```

**Solutions**:
```bash
# Increase replica count
kubectl scale deployment <service> --replicas=3

# Check for slow database queries
kubectl logs -f <service-pod> | grep "slow query"

# Verify connection pool settings
kubectl describe pod <service-pod> | grep -i pool
```

### Pod Eviction

**Symptoms**: Pods being evicted

**Diagnosis**:
```bash
kubectl describe node minikube | grep -A 5 "Pressure"
kubectl get events --sort-by='.lastTimestamp'
```

**Solutions**:
```bash
# Increase Minikube resources
minikube stop
minikube start --memory=10240 --cpus=6

# Add resource requests to prevent overcommitment
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
```

## Build Issues

### Docker Build Fails

**Diagnosis**:
```bash
docker build -t service-name:latest .
# Check error message
```

**Common Issues**:
1. **Node/Go/Java version mismatch**: Update Dockerfile base image
2. **Dependency installation fails**: Check network connectivity, package versions
3. **Build context too large**: Add files to .dockerignore

**Solutions**:
```bash
# Clean Docker cache
docker system prune -a

# Build with no cache
docker build --no-cache -t service-name:latest .

# Check Dockerfile syntax
docker build --check -t service-name:latest .
```

### Image Not Found

**Symptoms**: ImagePullBackOff

**Diagnosis**:
```bash
kubectl describe pod <pod-name>
# Look for: Failed to pull image
```

**Solutions**:
```bash
# Ensure using Minikube's Docker daemon
eval $(minikube docker-env)

# Verify image exists
docker images | grep <service-name>

# Rebuild image
./operations/scripts/build-all.sh

# Set imagePullPolicy to IfNotPresent
spec:
  containers:
  - name: service
    imagePullPolicy: IfNotPresent
```

## Minikube Issues

### Minikube Won't Start

**Diagnosis**:
```bash
minikube start
# Check error message

minikube logs
```

**Solutions**:
```bash
# Delete and recreate
minikube delete
minikube start --memory=8192 --cpus=4

# Try different driver
minikube start --driver=docker
# or
minikube start --driver=virtualbox

# Check system resources
free -h
df -h
```

### Minikube Slow Performance

**Solutions**:
```bash
# Increase resources
minikube stop
minikube start --memory=10240 --cpus=6

# Enable more addons
minikube addons enable metrics-server

# Check CPU throttling
minikube ssh
top
```

## Useful Debugging Commands

```bash
# Get all resources
kubectl get all

# Get events
kubectl get events --sort-by='.lastTimestamp'

# Describe resource
kubectl describe pod <pod-name>

# Get logs
kubectl logs -f <pod-name>
kubectl logs -f <pod-name> -c istio-proxy  # Sidecar logs

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/sh

# Port forward for local testing
kubectl port-forward <pod-name> 8080:8080

# Get resource usage
kubectl top pods
kubectl top nodes

# Check Istio configuration
istioctl analyze
istioctl proxy-status
istioctl proxy-config routes <pod-name>

# View service mesh in Kiali
kubectl port-forward -n istio-system svc/kiali 20001:20001
```

## Getting Help

1. Check pod logs: `kubectl logs -f <pod-name>`
2. Check pod events: `kubectl describe pod <pod-name>`
3. Check service endpoints: `kubectl get endpoints`
4. Analyze Istio config: `istioctl analyze`
5. View service mesh: Kiali dashboard
6. Check traces: Jaeger dashboard
7. View metrics: Grafana dashboards

## Emergency Recovery

If everything is broken:

```bash
# 1. Clean up everything
./operations/scripts/cleanup.sh

# 2. Restart Minikube
minikube stop
minikube start --memory=8192 --cpus=4

# 3. Reinstall Istio
./operations/scripts/install-istio.sh

# 4. Rebuild images
eval $(minikube docker-env)
./operations/scripts/build-all.sh

# 5. Redeploy services
./operations/scripts/deploy-all.sh
```
