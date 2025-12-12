# 🎁 BONUS Exercise: Monitoring with Prometheus & Grafana

## ⚠️ Important Note

**This is a BONUS exercise** - Complete this only after successfully finishing the main capstone project (Phases 1-7).

**Prerequisites:**
- ✅ Completed all 7 main phases
- ✅ Application running on Kubernetes
- ✅ Basic understanding of metrics and monitoring

**Estimated Time:** 2-3 hours

---

## 📊 What You'll Learn

- Install and configure Prometheus for metrics collection
- Set up Grafana for visualization
- Create custom dashboards
- Configure alerts
- Monitor application health and performance

---

## 🎯 Learning Objectives

By completing this bonus exercise, you will:
1. Understand metrics-based monitoring
2. Deploy Prometheus using Helm
3. Configure service discovery in Kubernetes
4. Create Grafana dashboards
5. Set up alerting rules
6. Monitor application and cluster metrics

---

## 📋 Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                    │
│                                                          │
│  ┌──────────────┐      ┌─────────────┐                 │
│  │              │      │             │                  │
│  │  Task Manager│─────▶│ Prometheus  │──────┐          │
│  │  Application │      │             │      │          │
│  │              │      └─────────────┘      │          │
│  └──────────────┘                           │          │
│        │                                    │          │
│        │ /metrics                           │          │
│        │                                    │          │
│  ┌──────────────┐                          │          │
│  │              │                           │          │
│  │  Node        │◀──────────────────────────┘          │
│  │  Exporter    │                                      │
│  │              │                                      │
│  └──────────────┘                                      │
│                                                         │
│                          ▲                              │
│                          │                              │
│                          │ Query                        │
│                          │                              │
│                    ┌─────────────┐                     │
│                    │             │                     │
│                    │   Grafana   │◀────── User         │
│                    │             │                     │
│                    └─────────────┘                     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 🚀 Part 1: Install Prometheus

### Step 1: Add Prometheus Helm Repository

**Ubuntu/macOS:**
```bash
# Add Prometheus community Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Update Helm repositories
helm repo update
```

**Windows PowerShell:**
```powershell
# Add Prometheus community Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Update Helm repositories
helm repo update
```

### Step 2: Create Namespace

**Ubuntu/macOS:**
```bash
# Create monitoring namespace
kubectl create namespace monitoring
```

**Windows PowerShell:**
```powershell
# Create monitoring namespace
kubectl create namespace monitoring
```

### Step 3: Install Prometheus Stack

Create a values file for Prometheus configuration:

**Ubuntu/macOS:**
```bash
cat > prometheus-values.yaml << 'EOF'
prometheus:
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false
    podMonitorSelectorNilUsesHelmValues: false
    retention: 7d
    storageSpec:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi

grafana:
  enabled: true
  adminPassword: admin123
  service:
    type: NodePort
    nodePort: 30300

alertmanager:
  enabled: true

nodeExporter:
  enabled: true

kubeStateMetrics:
  enabled: true
EOF
```

**Windows PowerShell:**
```powershell
@'
prometheus:
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false
    podMonitorSelectorNilUsesHelmValues: false
    retention: 7d
    storageSpec:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi

grafana:
  enabled: true
  adminPassword: admin123
  service:
    type: NodePort
    nodePort: 30300

alertmanager:
  enabled: true

nodeExporter:
  enabled: true

kubeStateMetrics:
  enabled: true
'@ | Out-File -FilePath prometheus-values.yaml -Encoding UTF8
```

**Install Prometheus Stack:**

**Ubuntu/macOS:**
```bash
# Install Prometheus and Grafana
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values prometheus-values.yaml

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana \
  -n monitoring --timeout=300s
```

**Windows PowerShell:**
```powershell
# Install Prometheus and Grafana
helm install prometheus prometheus-community/kube-prometheus-stack `
  --namespace monitoring `
  --values prometheus-values.yaml

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana `
  -n monitoring --timeout=300s
```

### Step 4: Verify Installation

**Ubuntu/macOS:**
```bash
# Check all pods in monitoring namespace
kubectl get pods -n monitoring

# Check services
kubectl get svc -n monitoring
```

**Windows PowerShell:**
```powershell
# Check all pods in monitoring namespace
kubectl get pods -n monitoring

# Check services
kubectl get svc -n monitoring
```

**Expected Output:**
```
NAME                                                   READY   STATUS
prometheus-kube-prometheus-operator-xxx                1/1     Running
prometheus-kube-state-metrics-xxx                      1/1     Running
prometheus-prometheus-node-exporter-xxx                1/1     Running
prometheus-grafana-xxx                                 3/3     Running
alertmanager-prometheus-kube-prometheus-alertmanager-0 2/2     Running
prometheus-prometheus-kube-prometheus-prometheus-0     2/2     Running
```

---

## 📊 Part 2: Access Grafana

### Method 1: Port Forward

**Ubuntu/macOS:**
```bash
# Forward Grafana port
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# Open browser
# Linux:
xdg-open http://localhost:3000
# macOS:
open http://localhost:3000
```

**Windows PowerShell:**
```powershell
# Forward Grafana port
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# Open browser
Start-Process "http://localhost:3000"
```

### Method 2: NodePort (if using Minikube/Kind)

**Ubuntu/macOS:**
```bash
# Get Minikube IP
minikube ip

# Access Grafana at http://<minikube-ip>:30300
```

**Windows PowerShell:**
```powershell
# Get Minikube IP
minikube ip

# Access Grafana at http://<minikube-ip>:30300
```

### Login Credentials
- **Username:** admin
- **Password:** admin123

---

## 🎨 Part 3: Configure Application Metrics

### Step 1: Add Metrics Endpoint to Application

Update the Node.js application to expose metrics:

**Ubuntu/macOS:**
```bash
# Navigate to app directory
cd app

# Install Prometheus client
npm install prom-client
```

**Windows PowerShell:**
```powershell
# Navigate to app directory
cd app

# Install Prometheus client
npm install prom-client
```

Create metrics configuration file:

**Create file:** `app/metrics.js`

```javascript
const client = require('prom-client');

// Create a Registry to register metrics
const register = new client.Registry();

// Add default metrics
client.collectDefaultMetrics({ register });

// Custom metrics
const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5]
});

const httpRequestTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

const tasksTotal = new client.Gauge({
  name: 'tasks_total',
  help: 'Total number of tasks',
  labelNames: ['status']
});

register.registerMetric(httpRequestDuration);
register.registerMetric(httpRequestTotal);
register.registerMetric(tasksTotal);

module.exports = {
  register,
  httpRequestDuration,
  httpRequestTotal,
  tasksTotal
};
```

### Step 2: Update server.js

Add metrics to your application. Insert this code in `server.js`:

```javascript
// At the top with other requires
const { register, httpRequestDuration, httpRequestTotal, tasksTotal } = require('./metrics');

// Add metrics endpoint (after other routes)
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Middleware to track metrics (add after express.json())
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration
      .labels(req.method, req.route?.path || req.path, res.statusCode)
      .observe(duration);
    
    httpRequestTotal
      .labels(req.method, req.route?.path || req.path, res.statusCode)
      .inc();
  });
  
  next();
});

// Update tasks endpoints to track gauge (in POST, PUT, DELETE handlers)
// After modifying tasks array:
tasksTotal.labels('total').set(tasks.length);
tasksTotal.labels('completed').set(tasks.filter(t => t.completed).length);
tasksTotal.labels('pending').set(tasks.filter(t => !t.completed).length);
```

### Step 3: Rebuild and Redeploy

**Ubuntu/macOS:**
```bash
# Build new Docker image
docker build -t your-username/task-manager:v2.0-metrics -f ../docker/Dockerfile .

# Push to Docker Hub
docker push your-username/task-manager:v2.0-metrics

# Update Kubernetes deployment
kubectl set image deployment/task-manager \
  task-manager=your-username/task-manager:v2.0-metrics \
  -n task-manager

# Wait for rollout
kubectl rollout status deployment/task-manager -n task-manager
```

**Windows PowerShell:**
```powershell
# Build new Docker image
docker build -t your-username/task-manager:v2.0-metrics -f ..\docker\Dockerfile .

# Push to Docker Hub
docker push your-username/task-manager:v2.0-metrics

# Update Kubernetes deployment
kubectl set image deployment/task-manager `
  task-manager=your-username/task-manager:v2.0-metrics `
  -n task-manager

# Wait for rollout
kubectl rollout status deployment/task-manager -n task-manager
```

### Step 4: Test Metrics Endpoint

**Ubuntu/macOS:**
```bash
# Port forward application
kubectl port-forward -n task-manager svc/task-manager 8080:80

# Test metrics endpoint (in new terminal)
curl http://localhost:8080/metrics
```

**Windows PowerShell:**
```powershell
# Port forward application
kubectl port-forward -n task-manager svc/task-manager 8080:80

# Test metrics endpoint (in new PowerShell window)
Invoke-WebRequest http://localhost:8080/metrics
```

---

## 🔍 Part 4: Configure Prometheus to Scrape Application

### Step 1: Create ServiceMonitor

**Create file:** `monitoring/servicemonitor.yaml`

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: task-manager-metrics
  namespace: monitoring
  labels:
    app: task-manager
spec:
  selector:
    matchLabels:
      app: task-manager
  namespaceSelector:
    matchNames:
      - task-manager
  endpoints:
  - port: http
    path: /metrics
    interval: 30s
```

### Step 2: Apply ServiceMonitor

**Ubuntu/macOS:**
```bash
# Apply ServiceMonitor
kubectl apply -f monitoring/servicemonitor.yaml

# Verify ServiceMonitor
kubectl get servicemonitor -n monitoring
```

**Windows PowerShell:**
```powershell
# Apply ServiceMonitor
kubectl apply -f monitoring\servicemonitor.yaml

# Verify ServiceMonitor
kubectl get servicemonitor -n monitoring
```

### Step 3: Verify Prometheus Targets

**Ubuntu/macOS:**
```bash
# Forward Prometheus port
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090

# Open browser
# Linux:
xdg-open http://localhost:9090/targets
# macOS:
open http://localhost:9090/targets
```

**Windows PowerShell:**
```powershell
# Forward Prometheus port
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090

# Open browser
Start-Process "http://localhost:9090/targets"
```

You should see `task-manager-metrics` in the targets list with status **UP**.

---

## 📈 Part 5: Create Grafana Dashboards

### Step 1: Access Grafana

Use the access method from Part 2 to open Grafana at http://localhost:3000

### Step 2: Add Prometheus Data Source

1. Login with admin/admin123
2. Go to **Configuration** → **Data Sources**
3. Click **Add data source**
4. Select **Prometheus**
5. Set URL: `http://prometheus-kube-prometheus-prometheus.monitoring.svc:9090`
6. Click **Save & Test**

### Step 3: Create Custom Dashboard

#### Option 1: Manual Creation

1. Click **+** → **Dashboard** → **Add new panel**
2. Use these queries:

**Panel 1: Request Rate**
```promql
rate(http_requests_total[5m])
```

**Panel 2: Request Duration**
```promql
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

**Panel 3: Tasks by Status**
```promql
tasks_total
```

**Panel 4: CPU Usage**
```promql
rate(container_cpu_usage_seconds_total{namespace="task-manager"}[5m])
```

**Panel 5: Memory Usage**
```promql
container_memory_usage_bytes{namespace="task-manager"}
```

**Panel 6: Pod Count**
```promql
count(kube_pod_info{namespace="task-manager"})
```

#### Option 2: Import Pre-built Dashboard

Create dashboard JSON file:

**Create file:** `monitoring/grafana-dashboard.json`

```json
{
  "dashboard": {
    "title": "Task Manager Application",
    "panels": [
      {
        "title": "HTTP Requests Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total{namespace=\"task-manager\"}[5m])",
            "legendFormat": "{{method}} {{route}}"
          }
        ],
        "type": "graph"
      },
      {
        "title": "Request Duration (95th percentile)",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket{namespace=\"task-manager\"}[5m]))"
          }
        ],
        "type": "graph"
      },
      {
        "title": "Total Tasks",
        "targets": [
          {
            "expr": "tasks_total",
            "legendFormat": "{{status}}"
          }
        ],
        "type": "stat"
      },
      {
        "title": "CPU Usage",
        "targets": [
          {
            "expr": "rate(container_cpu_usage_seconds_total{namespace=\"task-manager\"}[5m])"
          }
        ],
        "type": "graph"
      }
    ]
  }
}
```

**Import Dashboard:**

1. In Grafana, click **+** → **Import**
2. Upload the JSON file or paste the content
3. Select Prometheus data source
4. Click **Import**

---

## 🔔 Part 6: Configure Alerts

### Step 1: Create PrometheusRule

**Create file:** `monitoring/alerts.yaml`

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: task-manager-alerts
  namespace: monitoring
  labels:
    prometheus: kube-prometheus
spec:
  groups:
  - name: task-manager
    interval: 30s
    rules:
    - alert: HighErrorRate
      expr: |
        rate(http_requests_total{status_code=~"5.."}[5m]) > 0.05
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High error rate detected"
        description: "Error rate is above 5% for 5 minutes"
    
    - alert: HighResponseTime
      expr: |
        histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 2
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High response time detected"
        description: "95th percentile response time is above 2 seconds"
    
    - alert: PodDown
      expr: |
        kube_deployment_status_replicas_available{namespace="task-manager"} < 2
      for: 2m
      labels:
        severity: critical
      annotations:
        summary: "Pod count is low"
        description: "Less than 2 pods are running"
    
    - alert: HighMemoryUsage
      expr: |
        container_memory_usage_bytes{namespace="task-manager"} > 400000000
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High memory usage"
        description: "Container is using more than 400MB memory"
```

### Step 2: Apply Alert Rules

**Ubuntu/macOS:**
```bash
# Apply alert rules
kubectl apply -f monitoring/alerts.yaml

# Verify rules
kubectl get prometheusrule -n monitoring
```

**Windows PowerShell:**
```powershell
# Apply alert rules
kubectl apply -f monitoring\alerts.yaml

# Verify rules
kubectl get prometheusrule -n monitoring
```

### Step 3: View Alerts in Prometheus

**Ubuntu/macOS:**
```bash
# Access Prometheus
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090

# Open alerts page
# Linux:
xdg-open http://localhost:9090/alerts
# macOS:
open http://localhost:9090/alerts
```

**Windows PowerShell:**
```powershell
# Access Prometheus
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090

# Open alerts page
Start-Process "http://localhost:9090/alerts"
```

---

## 🧪 Part 7: Generate Load and Observe Metrics

### Step 1: Install Load Testing Tool

**Ubuntu:**
```bash
# Install hey
sudo apt-get update
sudo apt-get install -y hey

# Or download binary
wget https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64
chmod +x hey_linux_amd64
sudo mv hey_linux_amd64 /usr/local/bin/hey
```

**macOS:**
```bash
# Install hey
brew install hey
```

**Windows PowerShell (as Administrator):**
```powershell
# Install using Chocolatey
choco install hey

# Or download manually from GitHub releases
```

### Step 2: Generate Load

**Ubuntu/macOS:**
```bash
# Port forward application
kubectl port-forward -n task-manager svc/task-manager 8080:80 &

# Generate load (in another terminal)
hey -n 10000 -c 50 -m GET http://localhost:8080/api/tasks

# Generate POST requests
hey -n 1000 -c 10 -m POST -H "Content-Type: application/json" \
  -d '{"title":"Load test task","priority":"high"}' \
  http://localhost:8080/api/tasks
```

**Windows PowerShell:**
```powershell
# Port forward application (in one PowerShell window)
kubectl port-forward -n task-manager svc/task-manager 8080:80

# Generate load (in another PowerShell window)
hey -n 10000 -c 50 -m GET http://localhost:8080/api/tasks

# Generate POST requests
hey -n 1000 -c 10 -m POST -H "Content-Type: application/json" `
  -d '{\"title\":\"Load test task\",\"priority\":\"high\"}' `
  http://localhost:8080/api/tasks
```

### Step 3: Observe Metrics

1. **Open Grafana Dashboard**
2. **Watch metrics update in real-time**
3. **Observe:**
   - Request rate increasing
   - Response time changes
   - Task count changes
   - Resource utilization

---

## 📊 Part 8: Advanced Monitoring

### Create Comprehensive Dashboard

**Metrics to Include:**

1. **Application Metrics:**
   - HTTP request rate by endpoint
   - Response time percentiles (50th, 95th, 99th)
   - Error rate by status code
   - Task operations (create, update, delete)

2. **Kubernetes Metrics:**
   - Pod count and status
   - Container restarts
   - Resource usage (CPU, Memory)
   - Network I/O

3. **Node Metrics:**
   - Node CPU usage
   - Node memory usage
   - Disk I/O
   - Network traffic

### Sample PromQL Queries

**Request Rate by Endpoint:**
```promql
sum(rate(http_requests_total[5m])) by (route)
```

**Error Rate Percentage:**
```promql
sum(rate(http_requests_total{status_code=~"5.."}[5m])) / 
sum(rate(http_requests_total[5m])) * 100
```

**Memory Usage Percentage:**
```promql
(container_memory_usage_bytes / container_spec_memory_limit_bytes) * 100
```

**Pod Restart Count:**
```promql
sum(kube_pod_container_status_restarts_total{namespace="task-manager"})
```

---

## 🎯 Bonus Challenges

### Challenge 1: Create Alert for High Task Creation Rate
Create an alert that fires when more than 100 tasks are created per minute.

### Challenge 2: Dashboard with Multiple Environments
Modify dashboard to support filtering by environment (dev, staging, prod).

### Challenge 3: Custom Business Metrics
Add custom metrics like:
- Average time to complete a task
- Most used priority levels
- Peak usage hours

### Challenge 4: Integrate with Slack/Email
Configure AlertManager to send notifications to Slack or email.

---

## 🧹 Cleanup

### Remove Monitoring Stack

**Ubuntu/macOS:**
```bash
# Uninstall Prometheus stack
helm uninstall prometheus -n monitoring

# Delete namespace
kubectl delete namespace monitoring

# Remove application metrics code (optional)
cd app
npm uninstall prom-client
# Remove metrics.js and related code from server.js
```

**Windows PowerShell:**
```powershell
# Uninstall Prometheus stack
helm uninstall prometheus -n monitoring

# Delete namespace
kubectl delete namespace monitoring

# Remove application metrics code (optional)
cd app
npm uninstall prom-client
# Remove metrics.js and related code from server.js
```

---

## ✅ Verification Checklist

Before submitting, ensure you have:

- [ ] Prometheus installed and running
- [ ] Grafana accessible and configured
- [ ] Application exposing /metrics endpoint
- [ ] ServiceMonitor configured and targets showing UP
- [ ] At least one custom dashboard created
- [ ] Alert rules configured and visible
- [ ] Load test executed and metrics observed
- [ ] Screenshots of dashboards saved
- [ ] Documentation of custom queries used

---

## 📚 Resources

### Documentation
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [PromQL Basics](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Grafana Dashboard Best Practices](https://grafana.com/docs/grafana/latest/best-practices/)

### Useful Links
- [Prometheus Operators](https://github.com/prometheus-operator/prometheus-operator)
- [Grafana Dashboard Repository](https://grafana.com/grafana/dashboards/)
- [Node Exporter Metrics](https://github.com/prometheus/node_exporter)

---

## 🎓 Learning Outcomes

After completing this bonus exercise, you should be able to:

1. ✅ Deploy and configure Prometheus in Kubernetes
2. ✅ Set up Grafana dashboards
3. ✅ Instrument applications with custom metrics
4. ✅ Write PromQL queries
5. ✅ Configure alerting rules
6. ✅ Understand metrics-based monitoring
7. ✅ Perform load testing and analysis
8. ✅ Create comprehensive monitoring solutions

---

## 🏆 Bonus Points

**This bonus exercise is worth up to 10 extra points:**

| Task | Points | Description |
|------|--------|-------------|
| Basic Setup | 3 | Prometheus and Grafana installed |
| Application Metrics | 3 | Custom metrics exposed and scraped |
| Dashboard Creation | 2 | Custom dashboard with 5+ panels |
| Alerting | 2 | Alert rules configured and tested |

---

## 💡 Tips for Success

1. **Start Simple:** Get basic metrics working before adding complexity
2. **Use Labels:** Properly label your metrics for better filtering
3. **Test Queries:** Test PromQL queries in Prometheus before adding to Grafana
4. **Save Work:** Export dashboards as JSON for backup
5. **Document:** Keep notes on your custom metrics and queries

---

## ❓ Troubleshooting

### Prometheus Not Scraping Application

**Check:**
```bash
# Verify ServiceMonitor
kubectl describe servicemonitor task-manager-metrics -n monitoring

# Check Prometheus logs
kubectl logs -n monitoring prometheus-prometheus-kube-prometheus-prometheus-0 -c prometheus

# Verify service labels match
kubectl get svc task-manager -n task-manager --show-labels
```

### Grafana Can't Connect to Prometheus

**Check data source URL:**
```
http://prometheus-kube-prometheus-prometheus.monitoring.svc:9090
```

### Metrics Not Showing

**Verify metrics endpoint:**
```bash
kubectl port-forward -n task-manager svc/task-manager 8080:80
curl http://localhost:8080/metrics | grep -i task
```

---

**Congratulations on completing the bonus monitoring exercise! 🎉**

**Your application now has production-grade observability! 📊🚀**
