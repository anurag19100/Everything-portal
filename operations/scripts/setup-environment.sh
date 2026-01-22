#!/bin/bash
# Setup script for installing all prerequisites
# Run with: ./operations/scripts/setup-environment.sh

set -e

echo "========================================"
echo "Everything Portal - Environment Setup"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

print_info "Detected OS: ${MACHINE}"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_warning "Running as root. Some installations may require non-root user."
fi

# Install Docker
install_docker() {
    print_info "Installing Docker..."

    if command -v docker &> /dev/null; then
        print_info "Docker is already installed: $(docker --version)"
        return 0
    fi

    if [ "$MACHINE" == "Linux" ]; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
        print_info "Docker installed. Please log out and log back in for group changes to take effect."
    elif [ "$MACHINE" == "Mac" ]; then
        print_warning "Please install Docker Desktop for Mac from: https://www.docker.com/products/docker-desktop"
    fi
}

# Install kubectl
install_kubectl() {
    print_info "Installing kubectl..."

    if command -v kubectl &> /dev/null; then
        print_info "kubectl is already installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
        return 0
    fi

    if [ "$MACHINE" == "Linux" ]; then
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin/
    elif [ "$MACHINE" == "Mac" ]; then
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin/
    fi

    print_info "kubectl installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
}

# Install Minikube
install_minikube() {
    print_info "Installing Minikube..."

    if command -v minikube &> /dev/null; then
        print_info "Minikube is already installed: $(minikube version --short)"
        return 0
    fi

    if [ "$MACHINE" == "Linux" ]; then
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
        rm minikube-linux-amd64
    elif [ "$MACHINE" == "Mac" ]; then
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64
        sudo install minikube-darwin-amd64 /usr/local/bin/minikube
        rm minikube-darwin-amd64
    fi

    print_info "Minikube installed: $(minikube version --short)"
}

# Install Helm
install_helm() {
    print_info "Installing Helm..."

    if command -v helm &> /dev/null; then
        print_info "Helm is already installed: $(helm version --short)"
        return 0
    fi

    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    print_info "Helm installed: $(helm version --short)"
}

# Install Istio CLI
install_istioctl() {
    print_info "Installing Istio CLI..."

    if command -v istioctl &> /dev/null; then
        print_info "istioctl is already installed: $(istioctl version --short 2>/dev/null || echo 'version check failed')"
        return 0
    fi

    curl -L https://istio.io/downloadIstio | sh -

    # Find the istio directory and add to PATH
    ISTIO_DIR=$(find . -maxdepth 1 -name "istio-*" -type d | head -n 1)
    if [ -n "$ISTIO_DIR" ]; then
        sudo cp ${ISTIO_DIR}/bin/istioctl /usr/local/bin/
        print_info "istioctl installed and added to /usr/local/bin/"
        print_info "Istio samples available in: ${ISTIO_DIR}"
    fi
}

# Main installation flow
main() {
    print_info "Starting installation of prerequisites..."
    echo ""

    install_docker
    echo ""

    install_kubectl
    echo ""

    install_minikube
    echo ""

    install_helm
    echo ""

    install_istioctl
    echo ""

    print_info "========================================"
    print_info "Installation Complete!"
    print_info "========================================"
    echo ""
    print_info "Installed tools:"
    echo "  - Docker: $(command -v docker &> /dev/null && docker --version || echo 'Not installed')"
    echo "  - kubectl: $(command -v kubectl &> /dev/null && kubectl version --client --short 2>/dev/null || echo 'Not installed')"
    echo "  - Minikube: $(command -v minikube &> /dev/null && minikube version --short || echo 'Not installed')"
    echo "  - Helm: $(command -v helm &> /dev/null && helm version --short || echo 'Not installed')"
    echo "  - istioctl: $(command -v istioctl &> /dev/null && echo 'Installed' || echo 'Not installed')"
    echo ""
    print_info "Next steps:"
    echo "  1. Start Minikube: ./operations/scripts/start-minikube.sh"
    echo "  2. Install Istio: ./operations/scripts/install-istio.sh"
    echo "  3. Deploy services: ./operations/scripts/deploy-all.sh"
}

# Run main
main
