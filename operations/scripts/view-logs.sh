#!/bin/bash
# View logs for a specific service
# Usage: ./operations/scripts/view-logs.sh [service-name]

SERVICE=$1

if [ -z "$SERVICE" ]; then
    echo "Usage: $0 [service-name]"
    echo "Available services: python-service, go-service, java-service, claude-chat, secondary-ui, postgresql, mysql, mongodb"
    exit 1
fi

POD=$(kubectl get pods -l app=${SERVICE} -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POD" ]; then
    echo "No pod found for service: ${SERVICE}"
    exit 1
fi

echo "Viewing logs for ${SERVICE} (pod: ${POD})"
echo "Press Ctrl+C to exit"
echo "========================================"
kubectl logs -f ${POD}
