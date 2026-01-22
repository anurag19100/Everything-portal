#!/bin/bash
# Cleanup all deployed resources
# Run with: ./operations/scripts/cleanup.sh

set -e

echo "========================================"
echo "Cleaning Up All Resources"
echo "========================================"

# Confirmation prompt
read -p "This will delete all deployed resources. Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled"
    exit 1
fi

# Delete all deployments
echo "Deleting all deployments..."
kubectl delete deployments --all

# Delete all services (except kubernetes)
echo "Deleting all services..."
kubectl delete svc --all --field-selector metadata.name!=kubernetes

# Delete all statefulsets
echo "Deleting all statefulsets..."
kubectl delete statefulsets --all

# Delete Istio resources
echo "Deleting Istio resources..."
kubectl delete gateway --all
kubectl delete virtualservice --all
kubectl delete destinationrule --all

# Delete PVCs
echo "Deleting Persistent Volume Claims..."
kubectl delete pvc --all

echo ""
echo "========================================"
echo "Cleanup Complete!"
echo "========================================"
