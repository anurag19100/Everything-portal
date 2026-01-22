#!/bin/bash
# Deploy all services to Minikube with Istio
# Run with: ./operations/scripts/deploy-all.sh

set -e

echo "========================================"
echo "Deploying All Services to Kubernetes"
echo "========================================"

# Root directory
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
K8S_DIR="${ROOT_DIR}/infrastructure/kubernetes"

# Check if Minikube is running
if ! minikube status &> /dev/null; then
    echo "Error: Minikube is not running"
    exit 1
fi

# Check if Istio is installed
if ! kubectl get namespace istio-system &> /dev/null; then
    echo "Error: Istio is not installed"
    echo "Install Istio with: ./operations/scripts/install-istio.sh"
    exit 1
fi

# Deploy databases first
echo ""
echo "[1/7] Deploying Database Secrets and ConfigMaps..."
kubectl apply -f "${K8S_DIR}/base/databases/secrets.yaml"
kubectl apply -f "${K8S_DIR}/base/databases/configmaps.yaml"
echo "✓ Database secrets and configmaps deployed"

echo ""
echo "[2/7] Deploying Databases..."
kubectl apply -f "${K8S_DIR}/base/databases/postgresql-statefulset.yaml"
kubectl apply -f "${K8S_DIR}/base/databases/mysql-statefulset.yaml"
kubectl apply -f "${K8S_DIR}/base/databases/mongodb-statefulset.yaml"
echo "✓ Databases deployed"

echo ""
echo "Waiting for databases to be ready (this may take a few minutes)..."
kubectl wait --for=condition=ready pod -l app=postgresql --timeout=300s || echo "PostgreSQL not ready yet"
kubectl wait --for=condition=ready pod -l app=mysql --timeout=300s || echo "MySQL not ready yet"
kubectl wait --for=condition=ready pod -l app=mongodb --timeout=300s || echo "MongoDB not ready yet"

# Deploy backend services
echo ""
echo "[3/7] Deploying Backend Services..."
kubectl apply -f "${K8S_DIR}/base/python-service/"
kubectl apply -f "${K8S_DIR}/base/go-service/"
kubectl apply -f "${K8S_DIR}/base/java-service/"
echo "✓ Backend services deployed"

# Deploy frontend services
echo ""
echo "[4/7] Deploying Frontend Services..."
kubectl apply -f "${K8S_DIR}/base/claude-chat/"
kubectl apply -f "${K8S_DIR}/base/secondary-ui/"
echo "✓ Frontend services deployed"

# Deploy Istio Gateway and VirtualServices
echo ""
echo "[5/7] Deploying Istio Gateway..."
kubectl apply -f "${K8S_DIR}/istio/gateway.yaml"
echo "✓ Istio Gateway deployed"

echo ""
echo "[6/7] Deploying Istio VirtualServices..."
kubectl apply -f "${K8S_DIR}/istio/virtual-services.yaml"
echo "✓ Istio VirtualServices deployed"

echo ""
echo "[7/7] Deploying Istio DestinationRules..."
kubectl apply -f "${K8S_DIR}/istio/destination-rules.yaml"
kubectl apply -f "${K8S_DIR}/istio/peer-authentication.yaml"
echo "✓ Istio DestinationRules deployed"

# Wait for deployments to be ready
echo ""
echo "Waiting for all deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment --all || echo "Some deployments not ready yet"

# Display deployment status
echo ""
echo "========================================"
echo "Deployment Complete!"
echo "========================================"
echo ""
echo "Pod Status:"
kubectl get pods
echo ""
echo "Service Status:"
kubectl get svc
echo ""
echo "Istio Gateway:"
kubectl get gateway
echo ""

# Get Gateway URL
echo "Getting Istio Gateway URL..."
echo ""
./operations/scripts/get-gateway-url.sh
