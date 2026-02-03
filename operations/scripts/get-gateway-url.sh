#!/bin/bash
# Get the Istio Gateway URL
# Run with: ./operations/scripts/get-gateway-url.sh

set -e

echo "========================================"
echo "Istio Gateway Access Information"
echo "========================================"

# Get Minikube IP
MINIKUBE_IP=$(minikube ip)

# Get Istio Ingress Gateway NodePort
INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')

# Gateway URL
GATEWAY_URL="http://${MINIKUBE_IP}:${INGRESS_PORT}"

echo ""
echo "Istio Gateway URL: ${GATEWAY_URL}"
echo ""
echo "Service Endpoints:"
echo "  - Claude Chat:    ${GATEWAY_URL}/chat"
echo "  - Admin Dashboard: ${GATEWAY_URL}/admin"
echo "  - Java Service:   ${GATEWAY_URL}/api/java/health"
echo "  - Go Service:     ${GATEWAY_URL}/api/go/health"
echo "  - Python Service: ${GATEWAY_URL}/api/python/health"
echo ""
echo "Test the services:"
echo "  curl ${GATEWAY_URL}/api/python/health"
echo ""

# Try to test connectivity
echo "Testing connectivity..."
if command -v curl &> /dev/null; then
    echo ""
    for service in "python" "go" "java"; do
        echo "Testing ${service}-service..."
        curl -s "${GATEWAY_URL}/api/${service}/health" | head -n 5 || echo "  Service not ready yet"
    done
fi
