#!/bin/bash
# Quick setup checker - verifies all files are present and ready

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Everything Portal - Setup Check"
echo "================================"
echo ""

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
    else
        echo -e "${RED}✗${NC} $1 - MISSING"
    fi
}

check_executable() {
    if [ -x "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 (executable)"
    elif [ -f "$1" ]; then
        echo -e "${RED}⚠${NC} $1 (not executable - run: chmod +x $1)"
    else
        echo -e "${RED}✗${NC} $1 - MISSING"
    fi
}

echo "Master Scripts:"
check_executable "startup.sh"
check_executable "test-deployment.sh"
check_executable "check-setup.sh"

echo ""
echo "Documentation:"
check_file "README.md"
check_file "QUICKSTART.md"
check_file "GETTING_STARTED.md"
check_file "PROJECT_SUMMARY.md"
check_file "SCRIPTS.md"

echo ""
echo "Deployment Scripts:"
check_executable "operations/scripts/setup-environment.sh"
check_executable "operations/scripts/start-minikube.sh"
check_executable "operations/scripts/install-istio.sh"
check_executable "operations/scripts/build-all.sh"
check_executable "operations/scripts/deploy-all.sh"
check_executable "operations/scripts/get-gateway-url.sh"
check_executable "operations/scripts/cleanup.sh"
check_executable "operations/scripts/view-logs.sh"

echo ""
echo "Services:"
for svc in java-service go-service python-service claude-chat secondary-ui; do
    if [ -d "apps/backend/$svc" ] || [ -d "apps/frontend/$svc" ]; then
        echo -e "${GREEN}✓${NC} $svc"
    else
        echo -e "${RED}✗${NC} $svc - MISSING"
    fi
done

echo ""
echo "Dockerfiles:"
for df in apps/backend/*/Dockerfile apps/frontend/*/Dockerfile; do
    check_file "$df"
done

echo ""
echo "Kubernetes Manifests:"
K8S_COUNT=$(find infrastructure/kubernetes -name "*.yaml" | wc -l)
echo "  Found $K8S_COUNT manifest files"

echo ""
echo "================================"
echo "Setup check complete!"
echo ""
echo "Ready to deploy? Run: ./startup.sh"
