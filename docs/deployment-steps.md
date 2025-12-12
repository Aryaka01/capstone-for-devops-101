# Deployment Steps - DevOps Capstone Project

Quick reference guide for deploying the Task Manager application.

---

## 🚀 Quick Start (5 Minutes)

**Ubuntu/macOS:**
```bash
# 1. Clone repository
git clone https://github.com/your-username/devops-simple-capstone.git
cd devops-simple-capstone

# 2. Start local cluster (using Kind)
kind create cluster --name devops-capstone

# 3. Deploy application
kubectl apply -f kubernetes/

# 4. Access application
kubectl port-forward svc/task-manager 8080:80
# Visit http://localhost:8080
```

**Windows PowerShell:**
```powershell
# 1. Clone repository
git clone https://github.com/your-username/devops-simple-capstone.git
cd devops-simple-capstone

# 2. Start local cluster (using Kind)
kind create cluster --name devops-capstone

# 3. Deploy application
kubectl apply -f kubernetes\

# 4. Access application
kubectl port-forward svc/task-manager 8080:80
# Visit http://localhost:8080
```

---

## 📋 Detailed Deployment Methods

### Method 1: Direct Kubernetes Deployment

**Ubuntu/macOS:**
```bash
# Update image reference
export DOCKER_USER="your-dockerhub-username"
sed -i "s|your-dockerhub-username|$DOCKER_USER|g" kubernetes/deployment.yaml

# Apply manifests
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/ingress.yaml

# Wait for deployment
kubectl wait --for=condition=available deployment/task-manager --timeout=300s

# Check status
kubectl get pods -l app=task-manager
kubectl get svc task-manager
kubectl get ingress task-manager-ingress

# Access application
kubectl port-forward svc/task-manager 8080:80
```

**Windows PowerShell:**
```powershell
# Update image reference
$DOCKER_USER="your-dockerhub-username"
(Get-Content kubernetes\deployment.yaml) -replace 'your-dockerhub-username',$DOCKER_USER | Set-Content kubernetes\deployment.yaml

# Apply manifests
kubectl apply -f kubernetes\deployment.yaml
kubectl apply -f kubernetes\service.yaml
kubectl apply -f kubernetes\ingress.yaml

# Wait for deployment
kubectl wait --for=condition=available deployment/task-manager --timeout=300s

# Check status
kubectl get pods -l app=task-manager
kubectl get svc task-manager
kubectl get ingress task-manager-ingress
# Access application
kubectl port-forward svc/task-manager 8080:80
```

**Expected Output:**
```
deployment.apps/task-manager created
service/task-manager created
ingress.networking.k8s.io/task-manager-ingress created
```

---

### Method 2: Helm Deployment

**Ubuntu/macOS:**
```bash
# Update values
export DOCKER_USER="your-dockerhub-username"
sed -i "s|your-dockerhub-username|$DOCKER_USER|g" helm/task-manager/values.yaml

# Install with Helm
helm install task-manager ./helm/task-manager \
  --namespace task-manager \
  --create-namespace

# Verify installation
helm status task-manager -n task-manager
helm list -n task-manager

# Check resources
kubectl get all -n task-manager

# Upgrade (after changes)
helm upgrade task-manager ./helm/task-manager -n task-manager

# Rollback (if needed)
helm rollback task-manager -n task-manager
```

**Windows PowerShell:**
```powershell
# Update values
$DOCKER_USER="your-dockerhub-username"
(Get-Content helm\task-manager\values.yaml) -replace 'your-dockerhub-username',$DOCKER_USER | Set-Content helm\task-manager\values.yaml

# Install with Helm
helm install task-manager .\helm\task-manager `
  --namespace task-manager `
  --create-namespace

# Verify installation
helm status task-manager -n task-manager
helm list -n task-manager

# Check resources
kubectl get all -n task-manager

# Upgrade (after changes)
helm upgrade task-manager .\helm\task-manager -n task-manager

# Rollback (if needed)
helm rollback task-manager -n task-manager
```

**Expected Output:**
```
NAME: task-manager
LAST DEPLOYED: ...
NAMESPACE: task-manager
STATUS: deployed
```

---

### Method 3: Terraform + Helm

```bash
# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Review plan
terraform plan

# Apply configuration
terraform apply -auto-approve

# Export kubeconfig
export KUBECONFIG="$(terraform output -raw kubeconfig_path)"

# Verify cluster
kubectl cluster-info
kubectl get nodes

# Deploy application
cd ..
helm install task-manager ./helm/task-manager -n task-manager --create-namespace
```

**Expected Output:**
```
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:
cluster_name = "devops-capstone-cluster"
namespace = "task-manager"
```

---

### Method 4: ArgoCD GitOps Deployment

```bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Expose ArgoCD server
kubectl port-forward svc/argocd-server -n argocd 8082:443 &

# Get initial password
export ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD Password: $ARGOCD_PASSWORD"

# Login via CLI
argocd login localhost:8082 --username admin --password $ARGOCD_PASSWORD --insecure

# Update application manifest with your repository
export GIT_REPO="https://github.com/your-username/devops-simple-capstone.git"
sed -i "s|https://github.com/your-username/devops-simple-capstone.git|$GIT_REPO|g" argocd/application.yaml

# Create ArgoCD application
kubectl apply -f argocd/application.yaml

# Sync application
argocd app sync task-manager

# Monitor sync
argocd app wait task-manager --health

# Get application status
argocd app get task-manager
```

**Access ArgoCD UI:**
- URL: https://localhost:8082
- Username: admin
- Password: (from ARGOCD_PASSWORD variable)

---

## 🔧 Environment-Specific Deployments

### Development Environment

```bash
helm install task-manager ./helm/task-manager \
  --namespace task-manager-dev \
  --create-namespace \
  --set replicaCount=1 \
  --set image.tag=dev \
  --set resources.requests.memory=64Mi \
  --set resources.requests.cpu=50m
```

### Staging Environment

```bash
helm install task-manager ./helm/task-manager \
  --namespace task-manager-staging \
  --create-namespace \
  --set replicaCount=2 \
  --set image.tag=staging \
  --set ingress.hosts[0].host=task-manager-staging.local
```

### Production Environment

```bash
helm install task-manager ./helm/task-manager \
  --namespace task-manager-prod \
  --create-namespace \
  --set replicaCount=5 \
  --set image.tag=v1.0.0 \
  --set resources.limits.memory=512Mi \
  --set resources.limits.cpu=1000m \
  --set autoscaling.enabled=true \
  --set autoscaling.minReplicas=3 \
  --set autoscaling.maxReplicas=10 \
  --set ingress.hosts[0].host=task-manager.production.com \
  --set ingress.tls[0].secretName=task-manager-tls
```

---

## 🔍 Verification Steps

### Check Deployment Health

```bash
# Check pods
kubectl get pods -n task-manager
kubectl describe pods -n task-manager -l app=task-manager

# Check deployment
kubectl get deployment task-manager -n task-manager
kubectl describe deployment task-manager -n task-manager

# Check service
kubectl get svc task-manager -n task-manager
kubectl describe svc task-manager -n task-manager

# Check ingress
kubectl get ingress -n task-manager
kubectl describe ingress task-manager-ingress -n task-manager
```

### View Logs

```bash
# All pods
kubectl logs -n task-manager -l app=task-manager --tail=50

# Specific pod
kubectl logs -n task-manager <pod-name>

# Follow logs
kubectl logs -n task-manager -l app=task-manager -f

# Previous container (if crashed)
kubectl logs -n task-manager <pod-name> --previous
```

### Test Endpoints

```bash
# Port forward
kubectl port-forward -n task-manager svc/task-manager 8080:80

# In another terminal:
# Test health endpoint
curl http://localhost:8080/health

# Test ready endpoint
curl http://localhost:8080/ready

# Test API
curl http://localhost:8080/api/tasks

# Create task
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Test from CLI","priority":"high"}'
```

---

## 🔄 Update Deployments

### Rolling Update

```bash
# Update image
kubectl set image deployment/task-manager \
  task-manager=your-username/task-manager:v2.0 \
  -n task-manager

# Watch rollout
kubectl rollout status deployment/task-manager -n task-manager

# Check rollout history
kubectl rollout history deployment/task-manager -n task-manager
```

### Helm Upgrade

```bash
# Update values.yaml or use --set
helm upgrade task-manager ./helm/task-manager \
  -n task-manager \
  --set image.tag=v2.0

# Wait for upgrade
kubectl rollout status deployment/task-manager -n task-manager
```

### Rollback

```bash
# Kubernetes rollback
kubectl rollout undo deployment/task-manager -n task-manager

# Rollback to specific revision
kubectl rollout undo deployment/task-manager -n task-manager --to-revision=2

# Helm rollback
helm rollback task-manager -n task-manager
helm rollback task-manager 1 -n task-manager  # Rollback to revision 1
```

---

## 📊 Scaling

### Manual Scaling

```bash
# Scale up
kubectl scale deployment task-manager --replicas=5 -n task-manager

# Scale down
kubectl scale deployment task-manager --replicas=2 -n task-manager

# Verify
kubectl get pods -n task-manager -l app=task-manager
```

### Auto-scaling (HPA)

```bash
# Create HPA
kubectl autoscale deployment task-manager \
  --cpu-percent=70 \
  --min=3 \
  --max=10 \
  -n task-manager

# Check HPA
kubectl get hpa -n task-manager
kubectl describe hpa task-manager -n task-manager

# Delete HPA
kubectl delete hpa task-manager -n task-manager
```

---

## 🧹 Cleanup

### Remove Application Only

```bash
# Kubernetes
kubectl delete -f kubernetes/ -n task-manager

# Helm
helm uninstall task-manager -n task-manager
kubectl delete namespace task-manager

# ArgoCD
argocd app delete task-manager
kubectl delete -f argocd/application.yaml
```

### Remove Everything

```bash
# Delete ArgoCD
kubectl delete namespace argocd

# Delete cluster (Kind)
kind delete cluster --name devops-capstone

# Terraform
cd terraform
terraform destroy -auto-approve
```

---

## 📈 Monitoring

### Basic Monitoring

```bash
# Resource usage
kubectl top nodes
kubectl top pods -n task-manager

# Events
kubectl get events -n task-manager --sort-by='.lastTimestamp'

# Describe resources
kubectl describe deployment task-manager -n task-manager
kubectl describe pod <pod-name> -n task-manager
```

### Access Logs

```bash
# Stream logs
kubectl logs -n task-manager -l app=task-manager -f --max-log-requests=10

# Export logs
kubectl logs -n task-manager -l app=task-manager > task-manager-logs.txt
```

---

## 🎯 Quick Commands Cheatsheet

```bash
# Deploy
kubectl apply -f kubernetes/
helm install task-manager ./helm/task-manager -n task-manager --create-namespace

# Status
kubectl get all -n task-manager
helm status task-manager -n task-manager

# Logs
kubectl logs -n task-manager -l app=task-manager

# Access
kubectl port-forward -n task-manager svc/task-manager 8080:80

# Update
kubectl set image deployment/task-manager task-manager=image:newtag -n task-manager
helm upgrade task-manager ./helm/task-manager -n task-manager

# Rollback
kubectl rollout undo deployment/task-manager -n task-manager
helm rollback task-manager -n task-manager

# Scale
kubectl scale deployment task-manager --replicas=5 -n task-manager

# Delete
kubectl delete -f kubernetes/
helm uninstall task-manager -n task-manager
```

---

## 📚 Next Steps

After successful deployment:
1. ✅ Verify application is accessible
2. ✅ Test all CRUD operations
3. ✅ Check logs for errors
4. ✅ Monitor resource usage
5. ✅ Test rolling updates
6. ✅ Test rollback procedures
7. ✅ Configure CI/CD pipeline
8. ✅ Set up monitoring and alerts

---

**Need help?** Check [Troubleshooting Guide](troubleshooting.md) or [Solution Walkthrough](../SOLUTION.md)
