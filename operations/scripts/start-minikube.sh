#!/bin/bash
# Start Minikube with appropriate configuration for this project
# Run with: ./operations/scripts/start-minikube.sh

set -e

echo "========================================"
echo "Starting Minikube"
echo "========================================"

# Configuration
MEMORY="8192"  # 8GB
CPUS="4"
DRIVER="docker"  # Change to "virtualbox" or "hyperkit" if needed

# Check if Minikube is already running
if minikube status &> /dev/null; then
    echo "Minikube is already running"
    minikube status
    exit 0
fi

# Start Minikube
echo "Starting Minikube with ${CPUS} CPUs and ${MEMORY}MB memory..."
minikube start \
    --memory=${MEMORY} \
    --cpus=${CPUS} \
    --driver=${DRIVER} \
    --kubernetes-version=v1.28.0 \
    --addons=metrics-server \
    --addons=dashboard

# Verify Minikube is running
echo ""
echo "Verifying Minikube status..."
minikube status

# Enable necessary addons
echo ""
echo "Enabling Minikube addons..."
minikube addons enable metrics-server
minikube addons enable dashboard

# Configure Docker environment
echo ""
echo "Configuring Docker to use Minikube's Docker daemon..."
echo "Run the following command in your terminal:"
echo "  eval \$(minikube docker-env)"

# Display cluster info
echo ""
echo "Cluster information:"
kubectl cluster-info

echo ""
echo "========================================"
echo "Minikube started successfully!"
echo "========================================"
echo ""
echo "Useful commands:"
echo "  - View dashboard: minikube dashboard"
echo "  - SSH into node: minikube ssh"
echo "  - Stop Minikube: minikube stop"
echo "  - Delete Minikube: minikube delete"
echo "  - View logs: minikube logs"
echo ""
echo "Next step: Install Istio with ./operations/scripts/install-istio.sh"
