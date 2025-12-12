# Complete Solution Walkthrough

This document provides a detailed, step-by-step solution for the DevOps Capstone Project.

---

## 📖 Table of Contents

1. [Project Overview](#project-overview)
2. [Phase 1: Application Development](#phase-1-application-development)
3. [Phase 2: Containerization](#phase-2-containerization)
4. [Phase 3: Kubernetes Deployment](#phase-3-kubernetes-deployment)
5. [Phase 4: Helm Charts](#phase-4-helm-charts)
6. [Phase 5: Infrastructure as Code](#phase-5-infrastructure-as-code)
7. [Phase 6: CI/CD Pipeline](#phase-6-cicd-pipeline)
8. [Phase 7: GitOps with ArgoCD](#phase-7-gitops-with-argocd)
9. [Testing & Verification](#testing--verification)
10. [Best Practices](#best-practices)

---

## Project Overview

### What We're Building
A complete DevOps pipeline for a Task Manager web application that demonstrates:
- Source code management with Git
- Containerization with Docker
- Orchestration with Kubernetes
- Package management with Helm
- Infrastructure provisioning with Terraform
- CI/CD automation with Jenkins
- GitOps deployment with ArgoCD

### Architecture
```
Developer → Git Push → Jenkins Pipeline → Docker Build → Docker Hub
                              ↓
                    Update Kubernetes Manifests
                              ↓
                         ArgoCD Sync
                              ↓
                    Kubernetes Deployment
```

---

## Phase 1: Application Development

### Understanding the Application

The Task Manager is a simple Node.js application with:
- **Backend**: Express.js REST API
- **Frontend**: Vanilla JavaScript SPA
- **Features**: CRUD operations for tasks
- **Endpoints**:
  - `GET /` - Serve frontend
  - `GET /health` - Health check
  - `GET /ready` - Readiness check
  - `GET /api/tasks` - List all tasks
  - `POST /api/tasks` - Create task
  - `PUT /api/tasks/:id` - Update task
  - `DELETE /api/tasks/:id` - Delete task

### Key Files Explained

**server.js**
```javascript
// In-memory data storage (suitable for demo)
let tasks = [...];

// Express middleware for JSON and static files
app.use(express.json());
app.use(express.static('public'));

// Health checks for Kubernetes probes
app.get('/health', ...);  // Liveness probe
app.get('/ready', ...);   // Readiness probe
```

**package.json**
- Defines dependencies (express)
- Scripts for running the app
- Metadata about the project

### Local Testing

**Ubuntu/macOS:**
```bash
cd app
npm install
npm start
# Visit http://localhost:3000
```

**Windows PowerShell:**
```powershell
cd app
npm install
npm start
# Visit http://localhost:3000
```

**Expected Output:**
- Application starts on port 3000
- Can add, complete, and delete tasks
- Health check returns 200 OK

---

## Phase 2: Containerization

### Dockerfile Analysis

```dockerfile
# Multi-stage build for smaller image size
FROM node:18-alpine AS builder

# Stage 1: Install dependencies
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: Production image
FROM node:18-alpine
WORKDIR /app

# Security: Run as non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy only necessary files
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs server.js ./
COPY --chown=nodejs:nodejs public ./public

USER nodejs
EXPOSE 3000

# Health check for Docker
HEALTHCHECK --interval=30s --timeout=3s \
    CMD node -e "require('http').get('http://localhost:3000/health', ...)"

CMD ["node", "server.js"]
```

### Key Docker Concepts Used

1. **Multi-stage builds**: Reduces final image size
2. **Non-root user**: Security best practice
3. **Health checks**: Automatic container health monitoring
4. **.dockerignore**: Excludes unnecessary files

### Build and Test

**Ubuntu/macOS:**
```bash
# Build
docker build -t your-username/task-manager:v1.0 -f docker/Dockerfile ./app

# Test locally
docker run -d -p 8080:3000 --name test your-username/task-manager:v1.0

# Verify
curl http://localhost:8080/health
docker logs test

# Cleanup
docker stop test && docker rm test

# Push to registry
docker login
docker push your-username/task-manager:v1.0
```

**Windows PowerShell:**
```powershell
# Build
docker build -t your-username/task-manager:v1.0 -f docker\Dockerfile .\app

# Test locally
docker run -d -p 8080:3000 --name test your-username/task-manager:v1.0

# Verify
Invoke-WebRequest http://localhost:8080/health
docker logs test

# Cleanup
docker stop test; docker rm test

# Push to registry
docker login
docker push your-username/task-manager:v1.0
```
docker login
docker push your-username/task-manager:v1.0
docker tag your-username/task-manager:v1.0 your-username/task-manager:latest
docker push your-username/task-manager:latest
```

---

## Phase 3: Kubernetes Deployment

### Kubernetes Resources Explained

**1. Deployment (deployment.yaml)**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task-manager
spec:
  replicas: 3  # High availability
  selector:
    matchLabels:
      app: task-manager
  template:
    spec:
      containers:
      - name: task-manager
        image: your-username/task-manager:latest
        ports:
        - containerPort: 3000
        
        # Resource limits (important!)
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "500m"
        
        # Probes for health monitoring
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 10
          periodSeconds: 5
```

**Key Concepts:**
- **Replicas**: 3 pods for high availability
- **Resource requests/limits**: Prevent resource exhaustion
- **Liveness probe**: Restarts unhealthy pods
- **Readiness probe**: Controls traffic routing

**2. Service (service.yaml)**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: task-manager
spec:
  type: ClusterIP  # Internal service
  ports:
  - port: 80
    targetPort: 3000
  selector:
    app: task-manager
```

**Key Concepts:**
- **ClusterIP**: Internal load balancer
- **Port mapping**: External 80 → Container 3000
- **Selector**: Routes to pods with matching labels

**3. Ingress (ingress.yaml)**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: task-manager-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: task-manager.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: task-manager
            port:
              number: 80
```

**Key Concepts:**
- **Ingress**: HTTP(S) routing to services
- **Host-based routing**: Routes by domain name
- **Path-based routing**: Routes by URL path

### Deployment Steps

**Ubuntu/macOS:**
```bash
# 1. Update image reference
sed -i 's|your-dockerhub-username|YOUR_ACTUAL_USERNAME|g' kubernetes/deployment.yaml

# 2. Apply manifests
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/ingress.yaml

# 3. Verify deployment
kubectl get deployments
kubectl get pods -l app=task-manager
kubectl get services
kubectl get ingress

# 4. Check pod logs
kubectl logs -l app=task-manager --tail=50

# 5. Access application
kubectl port-forward svc/task-manager 8080:80
# Visit http://localhost:8080
```

**Windows PowerShell:**
```powershell
# 1. Update image reference
(Get-Content kubernetes\deployment.yaml) -replace 'your-dockerhub-username','YOUR_ACTUAL_USERNAME' | Set-Content kubernetes\deployment.yaml

# 2. Apply manifests
kubectl apply -f kubernetes\deployment.yaml
kubectl apply -f kubernetes\service.yaml
kubectl apply -f kubernetes\ingress.yaml

# 3. Verify deployment
kubectl get deployments
kubectl get pods -l app=task-manager
kubectl get services
kubectl get ingress

# 4. Check pod logs
kubectl logs -l app=task-manager --tail=50

# 5. Access application
kubectl port-forward svc/task-manager 8080:80
# Visit http://localhost:8080
```

### Troubleshooting

**Ubuntu/macOS:**
```bash
# Pod not starting
kubectl describe pod <pod-name>
kubectl logs <pod-name>

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# Test connectivity
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
# Inside pod: wget -O- http://task-manager/health
```

**Windows PowerShell:**
```powershell
# Pod not starting
kubectl describe pod <pod-name>
kubectl logs <pod-name>

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# Test connectivity
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
# Inside pod: wget -O- http://task-manager/health
```

---

## Phase 4: Helm Charts

### Why Helm?

Helm solves several problems:
1. **Templating**: Reuse manifests with different values
2. **Versioning**: Track deployments as releases
3. **Rollbacks**: Easy rollback to previous versions
4. **Package management**: Share charts like npm packages

### Helm Chart Structure

```
helm/task-manager/
├── Chart.yaml           # Chart metadata
├── values.yaml          # Default configuration
└── templates/
    ├── _helpers.tpl     # Template helpers
    ├── deployment.yaml  # Templated deployment
    ├── service.yaml     # Templated service
    ├── ingress.yaml     # Templated ingress
    └── serviceaccount.yaml
```

### Template Syntax Examples

```yaml
# values.yaml
replicaCount: 3
image:
  repository: myuser/task-manager
  tag: latest

# deployment.yaml template
replicas: {{ .Values.replicaCount }}
image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
```

### Helm Commands

**Ubuntu/macOS:**
```bash
# Install
helm install task-manager ./helm/task-manager -n task-manager --create-namespace

# Upgrade
helm upgrade task-manager ./helm/task-manager -n task-manager

# Rollback
helm rollback task-manager 1 -n task-manager

# List releases
helm list -n task-manager

# Get values
helm get values task-manager -n task-manager

# Uninstall
helm uninstall task-manager -n task-manager
```

**Windows PowerShell:**
```powershell
# Install
helm install task-manager .\helm\task-manager -n task-manager --create-namespace

# Upgrade
helm upgrade task-manager .\helm\task-manager -n task-manager

# Rollback
helm rollback task-manager 1 -n task-manager

# List releases
helm list -n task-manager

# Get values
helm get values task-manager -n task-manager

# Uninstall
helm uninstall task-manager -n task-manager
```

### Different Environment Configurations

**Ubuntu/macOS:**
```bash
# Development
helm install task-manager ./helm/task-manager \
  --set replicaCount=1 \
  --set image.tag=dev

# Production
helm install task-manager ./helm/task-manager \
  -f helm/task-manager/values-prod.yaml
```

**Windows PowerShell:**
```powershell
# Development
helm install task-manager .\helm\task-manager `
  --set replicaCount=1 `
  --set image.tag=dev

# Production
helm install task-manager .\helm\task-manager `
  -f helm\task-manager\values-prod.yaml
```

# Production
helm install task-manager ./helm/task-manager \
  --values helm/task-manager/values-prod.yaml
```

---

## Phase 5: Infrastructure as Code

### Terraform Configuration Explained

**main.tf**
```hcl
# Create Kind cluster
resource "kind_cluster" "default" {
  name = var.cluster_name
  
  kind_config {
    node {
      role = "control-plane"
      # Port mappings for ingress
      extra_port_mappings {
        container_port = 80
        host_port      = 80
      }
    }
    node { role = "worker" }
    node { role = "worker" }
  }
}

# Install NGINX Ingress Controller
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true
}

# Install ArgoCD
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  create_namespace = true
}
```

### Terraform Workflow

```bash
# 1. Initialize
terraform init

# 2. Validate
terraform validate

# 3. Plan (dry run)
terraform plan

# 4. Apply
terraform apply -auto-approve

# 5. Show state
terraform show

# 6. Outputs
terraform output

# 7. Destroy (cleanup)
terraform destroy -auto-approve
```

### Key Terraform Concepts

1. **Providers**: Interfaces to APIs (Kind, Kubernetes, Helm)
2. **Resources**: Infrastructure components to create
3. **Variables**: Parameterize configuration
4. **Outputs**: Information about created resources
5. **State**: Current infrastructure state

---

## Phase 6: CI/CD Pipeline

### Jenkins Pipeline Stages

**Jenkinsfile Breakdown**

```groovy
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE_NAME = 'user/task-manager'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        // 1. Get code from Git
        stage('Checkout') {
            steps {
                git branch: 'main', url: "${GIT_REPO}"
            }
        }
        
        // 2. Build Node.js app
        stage('Build Application') {
            steps {
                dir('app') {
                    sh 'npm install'
                    sh 'npm test'
                }
            }
        }
        
        // 3. Build Docker image
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }
        
        // 4. Test image
        stage('Test Docker Image') {
            steps {
                sh """
                    docker run -d --name test -p 3001:3000 ${DOCKER_IMAGE_NAME}:${IMAGE_TAG}
                    sleep 10
                    curl -f http://localhost:3001/health
                    docker stop test && docker rm test
                """
            }
        }
        
        // 5. Push to registry
        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", "dockerhub-credentials") {
                        docker.image("${DOCKER_IMAGE_NAME}:${IMAGE_TAG}").push()
                    }
                }
            }
        }
        
        // 6. Update K8s manifests
        stage('Update Kubernetes Manifests') {
            steps {
                sh """
                    sed -i 's|image:.*|image: ${DOCKER_IMAGE_NAME}:${IMAGE_TAG}|g' kubernetes/deployment.yaml
                    git add kubernetes/deployment.yaml
                    git commit -m "Update image to ${IMAGE_TAG}"
                """
            }
        }
        
        // 7. Deploy to K8s
        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh 'kubectl apply -f kubernetes/'
                    sh 'kubectl rollout status deployment/task-manager'
                }
            }
        }
    }
    
    post {
        success { echo '✅ Pipeline succeeded!' }
        failure { echo '❌ Pipeline failed!' }
        always { cleanWs() }
    }
}
```

### Jenkins Setup Steps

1. **Install Jenkins**
   ```bash
   docker run -d -p 8081:8080 -p 50000:50000 \
     -v jenkins_home:/var/jenkins_home \
     --name jenkins jenkins/jenkins:lts
   ```

2. **Configure Jenkins**
   - Install plugins: Docker, Kubernetes, Git
   - Add credentials:
     - Docker Hub (username/password)
     - Kubeconfig (secret file)
   - Create pipeline from SCM

3. **Configure Webhook** (for automatic builds)
   - GitHub: Settings → Webhooks
   - Add webhook: `http://jenkins-url/github-webhook/`

---

## Phase 7: GitOps with ArgoCD

### ArgoCD Concepts

**GitOps Principles:**
1. **Declarative**: Desired state in Git
2. **Versioned**: Git is source of truth
3. **Automated**: Automatic sync
4. **Auditable**: Git history

### ArgoCD Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: task-manager
  namespace: argocd
spec:
  # Source
  source:
    repoURL: https://github.com/user/repo.git
    targetRevision: main
    path: helm/task-manager
    helm:
      values: |
        replicaCount: 3
        image:
          tag: latest
  
  # Destination
  destination:
    server: https://kubernetes.default.svc
    namespace: task-manager
  
  # Sync policy
  syncPolicy:
    automated:
      prune: true      # Delete removed resources
      selfHeal: true   # Auto-sync on drift
```

### ArgoCD Workflow

```bash
# 1. Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 2. Access UI
kubectl port-forward svc/argocd-server -n argocd 8082:443

# 3. Get password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# 4. Login
argocd login localhost:8082

# 5. Create application
kubectl apply -f argocd/application.yaml

# 6. Sync
argocd app sync task-manager

# 7. Monitor
argocd app get task-manager
argocd app wait task-manager
```

### GitOps Workflow

1. Developer pushes code to Git
2. Jenkins builds and pushes Docker image
3. Jenkins updates manifest in Git
4. ArgoCD detects changes
5. ArgoCD syncs to Kubernetes
6. Application updated automatically

---

## Testing & Verification

### End-to-End Test

```bash
# 1. Make code change
echo "// Updated" >> app/server.js

# 2. Commit and push
git add app/server.js
git commit -m "Update server"
git push origin main

# 3. Watch Jenkins build
# Check http://localhost:8081/job/task-manager/

# 4. Watch ArgoCD sync
argocd app get task-manager --refresh

# 5. Verify deployment
kubectl rollout status deployment/task-manager -n task-manager
kubectl get pods -n task-manager

# 6. Test application
kubectl port-forward -n task-manager svc/task-manager 8080:80
curl http://localhost:8080/health
```

### Load Testing

```bash
# Install hey (HTTP load generator)
go install github.com/rakyll/hey@latest

# Run load test
hey -n 10000 -c 100 http://localhost:8080/api/tasks

# Monitor
kubectl top pods -n task-manager
```

---

## Best Practices

### 1. Docker
- ✅ Use multi-stage builds
- ✅ Run as non-root user
- ✅ Use specific base image tags
- ✅ Include health checks
- ✅ Keep images small

### 2. Kubernetes
- ✅ Set resource limits
- ✅ Use liveness/readiness probes
- ✅ Use namespaces
- ✅ Label everything
- ✅ Use ConfigMaps/Secrets for configuration

### 3. Helm
- ✅ Parameterize everything
- ✅ Use _helpers.tpl for common templates
- ✅ Version your charts
- ✅ Test before deploying

### 4. Terraform
- ✅ Use variables
- ✅ Store state remotely (S3, etc.)
- ✅ Use workspaces for environments
- ✅ Always run terraform plan

### 5. Jenkins
- ✅ Use credentials management
- ✅ Clean workspace after builds
- ✅ Send notifications
- ✅ Archive artifacts

### 6. ArgoCD
- ✅ Enable auto-sync
- ✅ Use health checks
- ✅ Implement RBAC
- ✅ Monitor sync status

---

## Common Issues & Solutions

### Issue 1: Image Pull Error
```bash
# Check image exists
docker pull your-username/task-manager:latest

# Check credentials
kubectl get secrets
kubectl create secret docker-registry regcred \
  --docker-server=docker.io \
  --docker-username=user \
  --docker-password=pass
```

### Issue 2: Pod CrashLoopBackOff
```bash
# Check logs
kubectl logs <pod-name>

# Check events
kubectl describe pod <pod-name>

# Common causes:
# - Application error
# - Missing environment variables
# - Health check failing too early
```

### Issue 3: ArgoCD Not Syncing
```bash
# Check application
argocd app get task-manager

# Force sync
argocd app sync task-manager --force

# Check diff
argocd app diff task-manager
```

---

## Conclusion

Congratulations! You've built a complete DevOps pipeline with:
- ✅ Version control (Git)
- ✅ Containerization (Docker)
- ✅ Orchestration (Kubernetes)
- ✅ Package management (Helm)
- ✅ Infrastructure as Code (Terraform)
- ✅ CI/CD automation (Jenkins)
- ✅ GitOps deployment (ArgoCD)

### Next Steps
1. Add monitoring (Prometheus/Grafana)
2. Implement centralized logging (ELK)
3. Add security scanning
4. Implement canary deployments
5. Set up disaster recovery

**Well done! 🎉**
