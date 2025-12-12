# Quick Start Guide - 5 Minute Setup

Get the Task Manager application running in just 5 minutes!

---

## 🚀 Prerequisites

Ensure you have:
- ✅ Docker Desktop running
- ✅ kubectl installed
- ✅ Git installed

---

## 📦 Option 1: Docker Only (Fastest)

**Ubuntu/macOS:**
```bash
# Run the application directly
docker run -d -p 8080:3000 --name task-manager \
  ghcr.io/devops-training/task-manager:latest

# Access the application
open http://localhost:8080
```

**Windows PowerShell:**
```powershell
# Run the application directly
docker run -d -p 8080:3000 --name task-manager `
  ghcr.io/devops-training/task-manager:latest

# Access the application
Start-Process http://localhost:8080
```

**That's it!** The application is now running.

---

## ☸️ Option 2: Kubernetes (Recommended)

### Step 1: Start Cluster (1 minute)

**Using Minikube (all platforms):**
```bash
minikube start
```

**Using Kind (all platforms):**
```bash
kind create cluster --name demo
```

### Step 2: Deploy Application (2 minutes)

**Ubuntu/macOS:**
```bash
# Clone repository
git clone https://github.com/your-username/devops-simple-capstone.git
cd devops-simple-capstone

# Deploy with kubectl
kubectl apply -f kubernetes/

# Wait for pods
kubectl wait --for=condition=ready pod -l app=task-manager --timeout=300s
```

**Windows PowerShell:**
```powershell
# Clone repository
git clone https://github.com/your-username/devops-simple-capstone.git
cd devops-simple-capstone

# Deploy with kubectl
kubectl apply -f kubernetes\

# Wait for pods
kubectl wait --for=condition=ready pod -l app=task-manager --timeout=300s
```

### Step 3: Access Application (1 minute)

**Ubuntu/macOS:**
```bash
# Port forward
kubectl port-forward svc/task-manager 8080:80

# Open browser
open http://localhost:8080
```

**Windows PowerShell:**
```powershell
# Port forward
kubectl port-forward svc/task-manager 8080:80

# Open browser
Start-Process http://localhost:8080
```

---

## 🎡 Option 3: Helm (Production-Like)

**Ubuntu/macOS:**
```bash
# Start cluster (if not already running)
minikube start

# Clone repository
git clone https://github.com/your-username/devops-simple-capstone.git
cd devops-simple-capstone

# Install with Helm
helm install demo ./helm/task-manager

# Access application
kubectl port-forward svc/demo-task-manager 8080:80
open http://localhost:8080
```

**Windows PowerShell:**
```powershell
# Start cluster (if not already running)
minikube start

# Clone repository
git clone https://github.com/your-username/devops-simple-capstone.git
cd devops-simple-capstone

# Install with Helm
helm install demo .\helm\task-manager

# Access application
kubectl port-forward svc/demo-task-manager 8080:80
Start-Process http://localhost:8080
```

---

## ✅ Verification

The application is working if you see:
- 🎨 Purple gradient background
- 📝 Task input field
- ✅ Pre-populated sample tasks
- ⚡ Ability to add, complete, and delete tasks

---

## 🧪 Quick Test

**Ubuntu/macOS:**
```bash
# Test health endpoint
curl http://localhost:8080/health

# Expected output: {"status":"healthy"}
```

**Windows PowerShell:**
```powershell
# Test health endpoint
Invoke-WebRequest http://localhost:8080/health

# Expected output: {"status":"healthy"}
```

# Expected response:
# {"status":"healthy","timestamp":"...","version":"1.0.0","uptime":...}

# Test API
curl http://localhost:8080/api/tasks

# Create a task
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Complete DevOps training","priority":"high"}'
```

---

## 🔍 Troubleshooting

### Application not accessible?

```bash
# Check if pods are running
kubectl get pods -l app=task-manager

# If not running, check logs
kubectl logs -l app=task-manager --tail=50

# Check events
kubectl get events --sort-by='.lastTimestamp'
```

### Port already in use?

```bash
# Use different port
kubectl port-forward svc/task-manager 8081:80
open http://localhost:8081
```

### Docker container not starting?

```bash
# Check logs
docker logs task-manager

# Remove and recreate
docker rm -f task-manager
docker run -d -p 8080:3000 --name task-manager \
  ghcr.io/devops-training/task-manager:latest
```

---

## 🧹 Cleanup

### Remove Docker Container
```bash
docker stop task-manager
docker rm task-manager
```

### Remove Kubernetes Deployment
```bash
kubectl delete -f kubernetes/
# OR
helm uninstall demo
```

### Remove Cluster
```bash
# Minikube
minikube delete

# Kind
kind delete cluster --name demo
```

---

## 📚 Next Steps

Now that you have it running:

1. **Explore the code**: Check out [app/server.js](app/server.js)
2. **Learn deployment**: Read [SETUP-GUIDE.md](SETUP-GUIDE.md)
3. **Build your own**: Follow [SOLUTION.md](SOLUTION.md)
4. **Deploy with CI/CD**: Setup Jenkins pipeline
5. **Enable GitOps**: Configure ArgoCD

---

## 🎯 Full DevOps Workflow

Ready for the complete experience?

```bash
# 1. Test locally
cd app
npm install
npm start

# 2. Build Docker image
docker build -t myusername/task-manager:v1 -f docker/Dockerfile ./app

# 3. Push to registry
docker push myusername/task-manager:v1

# 4. Deploy to Kubernetes
kubectl apply -f kubernetes/

# 5. Install with Helm
helm install task-manager ./helm/task-manager

# 6. Provision with Terraform
cd terraform
terraform init
terraform apply

# 7. Setup CI/CD with Jenkins
# Follow jenkins/Jenkinsfile

# 8. Enable GitOps with ArgoCD
kubectl apply -f argocd/application.yaml
```

---

## 💡 Tips

- **First time?** Start with Option 1 (Docker) to see the app
- **Learning K8s?** Use Option 2 (kubectl) to understand basics
- **Production-like?** Use Option 3 (Helm) for real scenarios
- **Full workflow?** Follow the complete setup guide

---

## 🆘 Need Help?

- 📖 [Setup Guide](SETUP-GUIDE.md) - Detailed instructions
- 🔧 [Troubleshooting](docs/troubleshooting.md) - Common issues
- 💡 [Solution](SOLUTION.md) - Complete walkthrough
- 📊 [Assessment](ASSESSMENT.md) - Grading criteria

---

## 🎓 Learning Path

### Day 1-2: Application & Docker
- Understand the application
- Build and run Docker container
- Push to Docker Hub

### Day 3-4: Kubernetes
- Deploy with kubectl
- Understand pods, services, ingress
- Test scaling and updates

### Day 5: Helm
- Create Helm chart
- Deploy with Helm
- Test upgrades and rollbacks

### Day 6: Terraform
- Provision infrastructure
- Manage state
- Understand IaC concepts

### Day 7-8: Jenkins
- Setup Jenkins
- Create CI/CD pipeline
- Automate deployment

### Day 9: ArgoCD
- Setup ArgoCD
- Configure GitOps
- Test automated sync

### Day 10: Integration
- End-to-end testing
- Documentation
- Presentation preparation

---

**🚀 Ready to become a DevOps expert? Let's get started!**
