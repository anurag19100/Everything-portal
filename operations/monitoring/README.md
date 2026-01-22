# Monitoring and Observability

This directory contains monitoring and observability configurations for the Everything Portal microservices.

## Overview

The monitoring stack includes:

- **Prometheus** - Metrics collection and storage
- **Grafana** - Metrics visualization and dashboards
- **Jaeger** - Distributed tracing
- **Kiali** - Service mesh visualization

All these tools are included with Istio's demo profile installation.

## Accessing Monitoring Tools

### Kiali (Service Mesh Dashboard)

```bash
kubectl port-forward -n istio-system svc/kiali 20001:20001
```

Then visit: http://localhost:20001

Kiali provides:
- Service graph visualization
- Traffic flow monitoring
- Configuration validation
- Distributed tracing integration

### Jaeger (Distributed Tracing)

```bash
kubectl port-forward -n istio-system svc/tracing 16686:16686
```

Then visit: http://localhost:16686

Jaeger shows:
- Request traces across services
- Latency breakdown
- Error tracking
- Service dependencies

### Grafana (Metrics Dashboards)

```bash
kubectl port-forward -n istio-system svc/grafana 3000:3000
```

Then visit: http://localhost:3000

Pre-installed dashboards:
- Istio Performance Dashboard
- Istio Service Dashboard
- Istio Workload Dashboard
- Istio Mesh Dashboard

### Prometheus (Metrics Database)

```bash
kubectl port-forward -n istio-system svc/prometheus 9090:9090
```

Then visit: http://localhost:9090

Use Prometheus to:
- Query metrics directly
- Create custom queries
- Test alerting rules
- Debug metric collection

## Custom Dashboard

To import the custom Grafana dashboard:

1. Access Grafana (see above)
2. Click "+" → "Import"
3. Upload `grafana-dashboard.json`
4. Select Prometheus as the data source

## Useful Metrics Queries

### Request Rate
```promql
sum(rate(istio_requests_total[5m])) by (destination_service_name)
```

### Error Rate
```promql
sum(rate(istio_requests_total{response_code=~"5.."}[5m])) by (destination_service_name)
```

### P95 Latency
```promql
histogram_quantile(0.95, sum(rate(istio_request_duration_milliseconds_bucket[5m])) by (destination_service_name, le))
```

### Pod CPU Usage
```promql
sum(rate(container_cpu_usage_seconds_total{namespace="default"}[5m])) by (pod)
```

### Pod Memory Usage
```promql
sum(container_memory_working_set_bytes{namespace="default"}) by (pod)
```

## Service-Specific Metrics

### Java Service (Spring Boot Actuator)
Endpoint: http://java-service:8080/actuator/prometheus

Metrics include:
- JVM memory usage
- Thread counts
- HTTP request metrics
- Database connection pool stats

### Python Service (FastAPI)
Endpoint: http://python-service:8082/metrics

Metrics include:
- Request duration
- Request count by endpoint
- Active connections
- Custom ML model metrics

### Go Service
Metrics exposed through Istio sidecar:
- Request counts
- Response times
- Error rates

## Alerting

To set up alerting:

1. Configure Prometheus Alertmanager
2. Define alert rules in `alert-rules.yaml`
3. Configure notification channels (Slack, email, PagerDuty)

Example alert rule:
```yaml
groups:
  - name: service-alerts
    rules:
      - alert: HighErrorRate
        expr: rate(istio_requests_total{response_code=~"5.."}[5m]) > 0.05
        for: 5m
        annotations:
          summary: "High error rate detected"
```

## Log Aggregation

For log aggregation, consider setting up:
- **EFK Stack** (Elasticsearch, Fluentd, Kibana)
- **Loki** (Lightweight log aggregation)

Logs can be viewed with:
```bash
kubectl logs -f <pod-name>
kubectl logs -f <pod-name> -c istio-proxy  # Sidecar logs
```

## Troubleshooting

### No Metrics in Grafana
- Verify Prometheus is scraping metrics: Check Prometheus targets at http://localhost:9090/targets
- Ensure Istio sidecar injection is enabled: `kubectl get pods` should show 2/2 containers

### Tracing Not Working
- Check Jaeger is running: `kubectl get pods -n istio-system | grep jaeger`
- Verify trace sampling rate in Istio configuration

### High Memory Usage
- Check metrics in Grafana
- Review pod resource limits
- Consider horizontal pod autoscaling

## Best Practices

1. **Set Resource Limits**: Define CPU/memory limits for all pods
2. **Monitor Golden Signals**: Latency, Traffic, Errors, Saturation
3. **Create Custom Dashboards**: Tailor to your specific use cases
4. **Set Up Alerts**: Don't wait for users to report issues
5. **Use Distributed Tracing**: Essential for debugging microservices
6. **Regular Reviews**: Analyze metrics weekly to identify trends
