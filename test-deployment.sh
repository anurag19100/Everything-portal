#!/bin/bash
################################################################################
# Everything Portal - Quick Deployment Test
#
# This script quickly checks if your deployment is working correctly.
#
# Usage: ./test-deployment.sh
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo ""
}

print_test() {
    echo -n -e "  ${BLUE}▶${NC} Testing $1... "
}

print_pass() {
    echo -e "${GREEN}✓ PASS${NC}"
}

print_fail() {
    echo -e "${RED}✗ FAIL${NC} - $1"
}

print_warn() {
    echo -e "${YELLOW}⚠ WARN${NC} - $1"
}

################################################################################
# Start Tests
################################################################################

print_header "Everything Portal - Deployment Test"

FAILED_TESTS=0
PASSED_TESTS=0
WARNING_TESTS=0

################################################################################
# Test 1: Check Prerequisites
################################################################################

print_header "1. Prerequisites Check"

print_test "Docker"
if command -v docker &> /dev/null; then
    print_pass
    ((PASSED_TESTS++))
else
    print_fail "Docker not installed"
    ((FAILED_TESTS++))
fi

print_test "kubectl"
if command -v kubectl &> /dev/null; then
    print_pass
    ((PASSED_TESTS++))
else
    print_fail "kubectl not installed"
    ((FAILED_TESTS++))
fi

print_test "Minikube"
if command -v minikube &> /dev/null; then
    print_pass
    ((PASSED_TESTS++))
else
    print_fail "Minikube not installed"
    ((FAILED_TESTS++))
fi

print_test "istioctl"
if command -v istioctl &> /dev/null; then
    print_pass
    ((PASSED_TESTS++))
else
    print_fail "istioctl not installed"
    ((FAILED_TESTS++))
fi

################################################################################
# Test 2: Check Minikube Status
################################################################################

print_header "2. Minikube Status"

print_test "Minikube Running"
if minikube status &> /dev/null; then
    print_pass
    ((PASSED_TESTS++))
else
    print_fail "Minikube is not running"
    ((FAILED_TESTS++))
    echo ""
    echo -e "${RED}ERROR: Minikube is not running. Cannot continue tests.${NC}"
    echo -e "Start Minikube with: ${YELLOW}./operations/scripts/start-minikube.sh${NC}"
    exit 1
fi

print_test "Kubernetes API"
if kubectl cluster-info &> /dev/null; then
    print_pass
    ((PASSED_TESTS++))
else
    print_fail "Cannot connect to Kubernetes API"
    ((FAILED_TESTS++))
fi

################################################################################
# Test 3: Check Istio
################################################################################

print_header "3. Istio Service Mesh"

print_test "Istio Namespace"
if kubectl get namespace istio-system &> /dev/null; then
    print_pass
    ((PASSED_TESTS++))
else
    print_fail "Istio namespace not found"
    ((FAILED_TESTS++))
fi

print_test "Istio Control Plane"
if kubectl get deployment -n istio-system istiod &> /dev/null; then
    if kubectl get deployment -n istio-system istiod -o jsonpath='{.status.availableReplicas}' | grep -q '[1-9]'; then
        print_pass
        ((PASSED_TESTS++))
    else
        print_warn "Istiod not ready"
        ((WARNING_TESTS++))
    fi
else
    print_fail "Istiod not found"
    ((FAILED_TESTS++))
fi

print_test "Istio Ingress Gateway"
if kubectl get deployment -n istio-system istio-ingressgateway &> /dev/null; then
    if kubectl get deployment -n istio-system istio-ingressgateway -o jsonpath='{.status.availableReplicas}' | grep -q '[1-9]'; then
        print_pass
        ((PASSED_TESTS++))
    else
        print_warn "Ingress gateway not ready"
        ((WARNING_TESTS++))
    fi
else
    print_fail "Ingress gateway not found"
    ((FAILED_TESTS++))
fi

################################################################################
# Test 4: Check Databases
################################################################################

print_header "4. Database Pods"

DATABASES=("postgresql" "mysql" "mongodb")

for db in "${DATABASES[@]}"; do
    print_test "$db"
    if kubectl get pod -l app=$db &> /dev/null; then
        STATUS=$(kubectl get pod -l app=$db -o jsonpath='{.items[0].status.phase}')
        if [ "$STATUS" = "Running" ]; then
            print_pass
            ((PASSED_TESTS++))
        else
            print_warn "Status: $STATUS"
            ((WARNING_TESTS++))
        fi
    else
        print_fail "Pod not found"
        ((FAILED_TESTS++))
    fi
done

################################################################################
# Test 5: Check Backend Services
################################################################################

print_header "5. Backend Services"

SERVICES=("java-service" "go-service" "python-service")

for svc in "${SERVICES[@]}"; do
    print_test "$svc"
    if kubectl get deployment $svc &> /dev/null; then
        REPLICAS=$(kubectl get deployment $svc -o jsonpath='{.status.availableReplicas}')
        if [ ! -z "$REPLICAS" ] && [ "$REPLICAS" -gt 0 ]; then
            print_pass
            ((PASSED_TESTS++))
        else
            print_warn "No replicas available"
            ((WARNING_TESTS++))
        fi
    else
        print_fail "Deployment not found"
        ((FAILED_TESTS++))
    fi
done

################################################################################
# Test 6: Check Frontend Services
################################################################################

print_header "6. Frontend Services"

FRONTENDS=("claude-chat" "secondary-ui")

for frontend in "${FRONTENDS[@]}"; do
    print_test "$frontend"
    if kubectl get deployment $frontend &> /dev/null; then
        REPLICAS=$(kubectl get deployment $frontend -o jsonpath='{.status.availableReplicas}')
        if [ ! -z "$REPLICAS" ] && [ "$REPLICAS" -gt 0 ]; then
            print_pass
            ((PASSED_TESTS++))
        else
            print_warn "No replicas available"
            ((WARNING_TESTS++))
        fi
    else
        print_fail "Deployment not found"
        ((FAILED_TESTS++))
    fi
done

################################################################################
# Test 7: Check Istio Configuration
################################################################################

print_header "7. Istio Configuration"

print_test "Gateway"
if kubectl get gateway everything-portal-gateway &> /dev/null; then
    print_pass
    ((PASSED_TESTS++))
else
    print_fail "Gateway not found"
    ((FAILED_TESTS++))
fi

print_test "VirtualServices"
VS_COUNT=$(kubectl get virtualservice 2>/dev/null | grep -v NAME | wc -l)
if [ "$VS_COUNT" -ge 5 ]; then
    print_pass
    ((PASSED_TESTS++))
else
    print_warn "Expected 5 VirtualServices, found $VS_COUNT"
    ((WARNING_TESTS++))
fi

print_test "DestinationRules"
DR_COUNT=$(kubectl get destinationrule 2>/dev/null | grep -v NAME | wc -l)
if [ "$DR_COUNT" -ge 3 ]; then
    print_pass
    ((PASSED_TESTS++))
else
    print_warn "Expected 3 DestinationRules, found $DR_COUNT"
    ((WARNING_TESTS++))
fi

################################################################################
# Test 8: Gateway Connectivity
################################################################################

print_header "8. Gateway Connectivity"

if command -v curl &> /dev/null; then
    MINIKUBE_IP=$(minikube ip)
    INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
    GATEWAY_URL="http://${MINIKUBE_IP}:${INGRESS_PORT}"

    # Test each service health endpoint
    BACKEND_SERVICES=("python" "go" "java")

    for svc in "${BACKEND_SERVICES[@]}"; do
        print_test "${svc}-service health"
        if curl -sf "${GATEWAY_URL}/api/${svc}/health" -m 5 &> /dev/null; then
            print_pass
            ((PASSED_TESTS++))
        else
            print_warn "Service not responding (may still be starting)"
            ((WARNING_TESTS++))
        fi
    done
else
    print_warn "curl not installed, skipping connectivity tests"
    ((WARNING_TESTS++))
fi

################################################################################
# Test 9: Pod Health
################################################################################

print_header "9. Pod Health Status"

print_test "All Pods Running"
NOT_RUNNING=$(kubectl get pods --field-selector=status.phase!=Running 2>/dev/null | grep -v NAME | wc -l)
if [ "$NOT_RUNNING" -eq 0 ]; then
    print_pass
    ((PASSED_TESTS++))
else
    print_warn "$NOT_RUNNING pods not running"
    ((WARNING_TESTS++))
fi

print_test "No CrashLooping Pods"
CRASH_LOOP=$(kubectl get pods 2>/dev/null | grep -c "CrashLoopBackOff" || echo "0")
if [ "$CRASH_LOOP" -eq 0 ]; then
    print_pass
    ((PASSED_TESTS++))
else
    print_fail "$CRASH_LOOP pods in CrashLoopBackOff"
    ((FAILED_TESTS++))
fi

################################################################################
# Summary
################################################################################

print_header "Test Summary"

TOTAL_TESTS=$((PASSED_TESTS + FAILED_TESTS + WARNING_TESTS))

echo ""
echo -e "${GREEN}✓ Passed:${NC}   $PASSED_TESTS/$TOTAL_TESTS"
echo -e "${YELLOW}⚠ Warnings:${NC} $WARNING_TESTS/$TOTAL_TESTS"
echo -e "${RED}✗ Failed:${NC}   $FAILED_TESTS/$TOTAL_TESTS"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    if [ $WARNING_TESTS -eq 0 ]; then
        echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}  ✓ ALL TESTS PASSED! Deployment is healthy! 🎉${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
        EXIT_CODE=0
    else
        echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
        echo -e "${YELLOW}  ⚠ Tests passed with warnings. Some services may${NC}"
        echo -e "${YELLOW}    still be starting up. Wait a few minutes.${NC}"
        echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
        EXIT_CODE=0
    fi
else
    echo -e "${RED}═══════════════════════════════════════════════════════${NC}"
    echo -e "${RED}  ✗ Some tests failed. Check the output above.${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════════${NC}"
    EXIT_CODE=1
fi

echo ""
echo -e "${CYAN}Useful Commands:${NC}"
echo -e "  ${BLUE}▶${NC} View pods:    kubectl get pods"
echo -e "  ${BLUE}▶${NC} View logs:    ./operations/scripts/view-logs.sh <service>"
echo -e "  ${BLUE}▶${NC} Get Gateway:  ./operations/scripts/get-gateway-url.sh"
echo -e "  ${BLUE}▶${NC} Troubleshoot: See docs/runbooks/troubleshooting.md"
echo ""

if command -v minikube &> /dev/null && minikube status &> /dev/null; then
    MINIKUBE_IP=$(minikube ip)
    INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}' 2>/dev/null || echo "")
    if [ ! -z "$INGRESS_PORT" ]; then
        GATEWAY_URL="http://${MINIKUBE_IP}:${INGRESS_PORT}"
        echo -e "${CYAN}Access URLs:${NC}"
        echo -e "  ${BLUE}▶${NC} Gateway:      ${YELLOW}${GATEWAY_URL}${NC}"
        echo -e "  ${BLUE}▶${NC} Claude Chat:  ${YELLOW}${GATEWAY_URL}/chat${NC}"
        echo -e "  ${BLUE}▶${NC} Admin:        ${YELLOW}${GATEWAY_URL}/admin${NC}"
        echo ""
    fi
fi

exit $EXIT_CODE
