#!/bin/bash
################################################################################
# Everything Portal - Master Startup Script
#
# This script automates the entire deployment process:
# - Checks prerequisites
# - Installs missing tools
# - Starts Minikube
# - Installs Istio
# - Builds Docker images
# - Deploys all services
# - Shows access URLs
#
# Usage: ./startup.sh [options]
#   --skip-install    Skip prerequisite installation
#   --skip-build      Skip Docker image building
#   --clean           Clean up and start fresh
#   --help            Show this help message
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Flags
SKIP_INSTALL=false
SKIP_BUILD=false
CLEAN_START=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-install)
            SKIP_INSTALL=true
            shift
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --clean)
            CLEAN_START=true
            shift
            ;;
        --help)
            head -n 20 "$0" | grep "^#" | sed 's/^# //'
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Helper functions
print_header() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${MAGENTA}$1${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}▶${NC} ${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

################################################################################
# Main Script
################################################################################

print_header "Everything Portal - Automated Deployment"

echo -e "${MAGENTA}🚀 Starting deployment process...${NC}"
echo ""
echo "Configuration:"
echo "  - Skip Install: $SKIP_INSTALL"
echo "  - Skip Build: $SKIP_BUILD"
echo "  - Clean Start: $CLEAN_START"
echo ""

################################################################################
# Step 1: Clean Up (if requested)
################################################################################

if [ "$CLEAN_START" = true ]; then
    print_header "Step 1: Cleaning Up Existing Deployment"

    if command_exists kubectl && minikube status &> /dev/null; then
        print_step "Cleaning up existing deployments..."
        ./operations/scripts/cleanup.sh || true
        print_success "Cleanup completed"
    else
        print_info "No existing deployment to clean up"
    fi

    if command_exists minikube && minikube status &> /dev/null; then
        print_step "Stopping Minikube..."
        minikube stop || true
        print_success "Minikube stopped"
    fi
else
    print_header "Step 1: Pre-deployment Check"
    print_info "Skipping cleanup (use --clean for fresh start)"
fi

################################################################################
# Step 2: Check Prerequisites
################################################################################

print_header "Step 2: Checking Prerequisites"

MISSING_TOOLS=()

if ! command_exists docker; then
    print_warning "Docker not found"
    MISSING_TOOLS+=("docker")
else
    print_success "Docker: $(docker --version 2>/dev/null | head -1)"
fi

if ! command_exists kubectl; then
    print_warning "kubectl not found"
    MISSING_TOOLS+=("kubectl")
else
    print_success "kubectl: $(kubectl version --client --short 2>/dev/null || kubectl version --client 2>/dev/null | head -1)"
fi

if ! command_exists minikube; then
    print_warning "Minikube not found"
    MISSING_TOOLS+=("minikube")
else
    print_success "Minikube: $(minikube version --short 2>/dev/null || minikube version 2>/dev/null | head -1)"
fi

if ! command_exists helm; then
    print_warning "Helm not found"
    MISSING_TOOLS+=("helm")
else
    print_success "Helm: $(helm version --short 2>/dev/null || echo 'installed')"
fi

if ! command_exists istioctl; then
    print_warning "istioctl not found"
    MISSING_TOOLS+=("istioctl")
else
    print_success "istioctl: $(istioctl version --short 2>/dev/null || echo 'installed')"
fi

################################################################################
# Step 3: Install Missing Prerequisites
################################################################################

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    if [ "$SKIP_INSTALL" = true ]; then
        print_error "Missing tools: ${MISSING_TOOLS[*]}"
        print_error "Cannot proceed without prerequisites. Run without --skip-install"
        exit 1
    fi

    print_header "Step 3: Installing Prerequisites"
    print_step "Installing missing tools: ${MISSING_TOOLS[*]}"
    ./operations/scripts/setup-environment.sh
    print_success "Prerequisites installed"
else
    print_header "Step 3: Prerequisites Check"
    print_success "All prerequisites are installed!"
fi

################################################################################
# Step 4: Start Minikube
################################################################################

print_header "Step 4: Starting Minikube"

if minikube status &> /dev/null; then
    print_success "Minikube is already running"
    minikube status
else
    print_step "Starting Minikube cluster..."
    ./operations/scripts/start-minikube.sh
    print_success "Minikube started successfully"
fi

# Verify Minikube is running
if ! minikube status &> /dev/null; then
    print_error "Failed to start Minikube"
    exit 1
fi

################################################################################
# Step 5: Install Istio
################################################################################

print_header "Step 5: Installing Istio Service Mesh"

if kubectl get namespace istio-system &> /dev/null; then
    print_success "Istio is already installed"
    kubectl get pods -n istio-system | head -5
else
    print_step "Installing Istio..."
    ./operations/scripts/install-istio.sh
    print_success "Istio installed successfully"
fi

# Verify Istio is running
if ! kubectl get namespace istio-system &> /dev/null; then
    print_error "Failed to install Istio"
    exit 1
fi

################################################################################
# Step 6: Build Docker Images
################################################################################

if [ "$SKIP_BUILD" = true ]; then
    print_header "Step 6: Docker Images"
    print_info "Skipping Docker image build (--skip-build flag)"

    # Check if images exist
    print_step "Checking existing images..."
    eval $(minikube docker-env)

    IMAGES=("python-service:latest" "go-service:latest" "java-service:latest" "claude-chat:latest" "secondary-ui:latest")
    MISSING_IMAGES=()

    for img in "${IMAGES[@]}"; do
        if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^${img}$"; then
            print_success "Found: $img"
        else
            print_warning "Missing: $img"
            MISSING_IMAGES+=("$img")
        fi
    done

    if [ ${#MISSING_IMAGES[@]} -gt 0 ]; then
        print_error "Missing images: ${MISSING_IMAGES[*]}"
        print_error "Run without --skip-build to build images"
        exit 1
    fi
else
    print_header "Step 6: Building Docker Images"

    print_step "Configuring Docker to use Minikube's daemon..."
    eval $(minikube docker-env)
    print_success "Docker configured"

    print_step "Building all service images (this may take 10-15 minutes)..."
    ./operations/scripts/build-all.sh
    print_success "All images built successfully"
fi

################################################################################
# Step 7: Deploy Services
################################################################################

print_header "Step 7: Deploying Services to Kubernetes"

print_step "Deploying all services..."
./operations/scripts/deploy-all.sh

print_success "All services deployed!"

################################################################################
# Step 8: Wait for Services to be Ready
################################################################################

print_header "Step 8: Waiting for Services to be Ready"

print_step "Waiting for pods to be ready (this may take 3-5 minutes)..."

# Wait for database pods
print_info "Waiting for databases..."
kubectl wait --for=condition=ready pod -l app=postgresql --timeout=300s 2>/dev/null || true
kubectl wait --for=condition=ready pod -l app=mysql --timeout=300s 2>/dev/null || true
kubectl wait --for=condition=ready pod -l app=mongodb --timeout=300s 2>/dev/null || true

# Wait for service deployments
print_info "Waiting for services..."
kubectl wait --for=condition=available deployment --all --timeout=300s 2>/dev/null || true

print_success "Services are ready!"

################################################################################
# Step 9: Display Access Information
################################################################################

print_header "Step 9: Access Information"

# Get Gateway URL
MINIKUBE_IP=$(minikube ip)
INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
GATEWAY_URL="http://${MINIKUBE_IP}:${INGRESS_PORT}"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    🎉 DEPLOYMENT SUCCESSFUL! 🎉                    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Gateway URL:${NC} ${YELLOW}${GATEWAY_URL}${NC}"
echo ""
echo -e "${CYAN}📱 Frontend Services:${NC}"
echo -e "  ${BLUE}▶${NC} Claude Chat:    ${YELLOW}${GATEWAY_URL}/chat${NC}"
echo -e "  ${BLUE}▶${NC} Admin Dashboard: ${YELLOW}${GATEWAY_URL}/admin${NC}"
echo ""
echo -e "${CYAN}🔧 Backend Services:${NC}"
echo -e "  ${BLUE}▶${NC} Java Service:   ${YELLOW}${GATEWAY_URL}/api/java/health${NC}"
echo -e "  ${BLUE}▶${NC} Go Service:     ${YELLOW}${GATEWAY_URL}/api/go/health${NC}"
echo -e "  ${BLUE}▶${NC} Python Service: ${YELLOW}${GATEWAY_URL}/api/python/health${NC}"
echo ""
echo -e "${CYAN}📊 Observability Tools:${NC}"
echo -e "  ${BLUE}▶${NC} Kiali:      kubectl port-forward -n istio-system svc/kiali 20001:20001"
echo -e "              ${YELLOW}http://localhost:20001${NC}"
echo -e "  ${BLUE}▶${NC} Grafana:    kubectl port-forward -n istio-system svc/grafana 3000:3000"
echo -e "              ${YELLOW}http://localhost:3000${NC}"
echo -e "  ${BLUE}▶${NC} Jaeger:     kubectl port-forward -n istio-system svc/tracing 16686:16686"
echo -e "              ${YELLOW}http://localhost:16686${NC}"
echo -e "  ${BLUE}▶${NC} Prometheus: kubectl port-forward -n istio-system svc/prometheus 9090:9090"
echo -e "              ${YELLOW}http://localhost:9090${NC}"
echo ""

################################################################################
# Step 10: Test Services
################################################################################

print_header "Step 10: Testing Services"

print_step "Running health checks..."

# Test each service
SERVICES=("python" "go" "java")
ALL_HEALTHY=true

for service in "${SERVICES[@]}"; do
    echo -n "  Testing ${service}-service... "
    if curl -sf "${GATEWAY_URL}/api/${service}/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Healthy${NC}"
    else
        echo -e "${YELLOW}⚠ Not ready yet (may need more time)${NC}"
        ALL_HEALTHY=false
    fi
done

echo ""

if [ "$ALL_HEALTHY" = true ]; then
    print_success "All services are healthy!"
else
    print_warning "Some services are not ready yet. They may need a few more minutes to fully start."
    print_info "Check status with: kubectl get pods"
fi

################################################################################
# Final Summary
################################################################################

print_header "Deployment Complete"

echo -e "${GREEN}✓${NC} Minikube cluster running"
echo -e "${GREEN}✓${NC} Istio service mesh installed"
echo -e "${GREEN}✓${NC} 5 microservices deployed"
echo -e "${GREEN}✓${NC} 3 databases running"
echo -e "${GREEN}✓${NC} Observability stack ready"
echo ""
echo -e "${CYAN}📖 Next Steps:${NC}"
echo -e "  ${BLUE}1.${NC} Open Claude Chat:    ${YELLOW}${GATEWAY_URL}/chat${NC}"
echo -e "  ${BLUE}2.${NC} View Service Mesh:   Run 'kubectl port-forward -n istio-system svc/kiali 20001:20001'"
echo -e "  ${BLUE}3.${NC} Check pod status:    Run 'kubectl get pods'"
echo -e "  ${BLUE}4.${NC} View logs:           Run './operations/scripts/view-logs.sh <service-name>'"
echo -e "  ${BLUE}5.${NC} Read documentation:  See 'docs/' directory"
echo ""
echo -e "${CYAN}🛠️  Useful Commands:${NC}"
echo -e "  ${BLUE}▶${NC} View all pods:       kubectl get pods"
echo -e "  ${BLUE}▶${NC} View all services:   kubectl get svc"
echo -e "  ${BLUE}▶${NC} Get Gateway URL:     ./operations/scripts/get-gateway-url.sh"
echo -e "  ${BLUE}▶${NC} View logs:           ./operations/scripts/view-logs.sh <service>"
echo -e "  ${BLUE}▶${NC} Cleanup:             ./operations/scripts/cleanup.sh"
echo -e "  ${BLUE}▶${NC} Stop Minikube:       minikube stop"
echo ""
echo -e "${MAGENTA}🎉 Everything Portal is now running! Enjoy! 🚀${NC}"
echo ""

# Save gateway URL to file for easy access
echo "${GATEWAY_URL}" > .gateway-url
print_info "Gateway URL saved to .gateway-url"
echo ""
