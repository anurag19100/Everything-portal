#!/bin/bash
# Build all Docker images for the microservices
# Run with: ./operations/scripts/build-all.sh

set -e

echo "========================================"
echo "Building All Docker Images"
echo "========================================"

# Use Minikube's Docker daemon
echo "Configuring Docker to use Minikube's Docker daemon..."
eval $(minikube docker-env)

# Root directory
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Build Python Service
echo ""
echo "[1/5] Building Python Service..."
docker build -t python-service:latest "${ROOT_DIR}/apps/backend/python-service"
echo "✓ Python Service built successfully"

# Build Go Service
echo ""
echo "[2/5] Building Go Service..."
docker build -t go-service:latest "${ROOT_DIR}/apps/backend/go-service"
echo "✓ Go Service built successfully"

# Build Java Service
echo ""
echo "[3/5] Building Java Service..."
docker build -t java-service:latest "${ROOT_DIR}/apps/backend/java-service"
echo "✓ Java Service built successfully"

# Build Claude Chat Frontend
echo ""
echo "[4/5] Building Claude Chat Frontend..."
docker build -t claude-chat:latest "${ROOT_DIR}/apps/frontend/claude-chat"
echo "✓ Claude Chat built successfully"

# Build Secondary UI
echo ""
echo "[5/5] Building Secondary UI..."
docker build -t secondary-ui:latest "${ROOT_DIR}/apps/frontend/secondary-ui"
echo "✓ Secondary UI built successfully"

echo ""
echo "========================================"
echo "All Images Built Successfully!"
echo "========================================"
echo ""
echo "Built images:"
docker images | grep -E "(python-service|go-service|java-service|claude-chat|secondary-ui)"

echo ""
echo "Next step: Deploy services with ./operations/scripts/deploy-all.sh"
