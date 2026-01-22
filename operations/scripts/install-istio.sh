#!/bin/bash
# Install Istio service mesh on Minikube
# Run with: ./operations/scripts/install-istio.sh

set -e

echo "========================================"
echo "Installing Istio Service Mesh"
echo "========================================"

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed"
    exit 1
fi

# Check if istioctl is available
if ! command -v istioctl &> /dev/null; then
    echo "Error: istioctl is not installed"
    echo "Run ./operations/scripts/setup-environment.sh first"
    exit 1
fi

# Check if Minikube is running
if ! minikube status &> /dev/null; then
    echo "Error: Minikube is not running"
    echo "Start Minikube with: ./operations/scripts/start-minikube.sh"
    exit 1
fi

# Install Istio with demo profile (includes Kiali, Jaeger, Prometheus, Grafana)
echo "Installing Istio with demo profile..."
istioctl install --set profile=demo -y

# Wait for Istio components to be ready
echo ""
echo "Waiting for Istio components to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment --all -n istio-system

# Enable automatic sidecar injection for default namespace
echo ""
echo "Enabling automatic sidecar injection for default namespace..."
kubectl label namespace default istio-injection=enabled --overwrite

# Verify installation
echo ""
echo "Verifying Istio installation..."
istioctl verify-install

# Display Istio components
echo ""
echo "Istio components:"
kubectl get pods -n istio-system
kubectl get svc -n istio-system

# Get Istio Gateway URL
echo ""
echo "========================================"
echo "Istio installed successfully!"
echo "========================================"
echo ""
echo "Istio components installed:"
echo "  - Istiod (Control Plane)"
echo "  - Istio Ingress Gateway"
echo "  - Istio Egress Gateway"
echo "  - Kiali (Service Mesh Visualization)"
echo "  - Jaeger (Distributed Tracing)"
echo "  - Prometheus (Metrics)"
echo "  - Grafana (Dashboards)"
echo ""
echo "Access observability tools:"
echo "  - Kiali: kubectl port-forward -n istio-system svc/kiali 20001:20001"
echo "  - Jaeger: kubectl port-forward -n istio-system svc/tracing 16686:16686"
echo "  - Grafana: kubectl port-forward -n istio-system svc/grafana 3000:3000"
echo "  - Prometheus: kubectl port-forward -n istio-system svc/prometheus 9090:9090"
echo ""
echo "Next steps:"
echo "  1. Deploy databases: kubectl apply -f infrastructure/kubernetes/base/databases/"
echo "  2. Build services: ./operations/scripts/build-all.sh"
echo "  3. Deploy services: ./operations/scripts/deploy-all.sh"
