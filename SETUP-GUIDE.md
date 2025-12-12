# Complete Setup Guide - DevOps Capstone Project

This guide provides detailed instructions for setting up your development environment and deploying the Task Manager application.

---

## 📦 Prerequisites Installation

### 1. Install Git

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y git
```

**macOS:**
```bash
# Using Homebrew
brew install git

# Or download from: https://git-scm.com/download/mac
```

**Windows:**
```powershell
# Using winget
winget install Git.Git

# Or using Chocolatey
choco install git

# Or download from: https://git-scm.com/download/win
```

**Verify installation (all platforms):**
```bash
git --version
```

---

### 2. Install Docker Desktop
Download and install from: https://www.docker.com/products/docker-desktop

Verify:
```bash
docker --version
docker compose version
```

---

### 3. Install kubectl
**Windows:**
```powershell
choco install kubernetes-cli
```

**macOS:**
```bash
brew install kubectl
```

**Linux:**
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

Verify:
```bash
kubectl version --client
```

---

### 4. Install Minikube or Kind

**Option A: Minikube**
```bash
# Windows (using Chocolatey)
choco install minikube

# macOS
brew install minikube

# Linux
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

**Option B: Kind (Kubernetes in Docker)**
```bash
# Windows (using Chocolatey)
choco install kind

# macOS
brew install kind

# Linux
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

---

### 5. Install Helm
```bash
# Windows
choco install kubernetes-helm

# macOS
brew install helm

# Linux
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

Verify:
```bash
helm version
```

---

### 6. Install Terraform
```bash
# Windows
choco install terraform

# macOS
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Linux
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

Verify:
```bash
terraform version
```

---

### 7. Install Node.js
Download from: https://nodejs.org/ (LTS version)

Verify:
```bash
node --version
npm --version
```

---

### 8. Install ArgoCD CLI
```bash
# Windows
choco install argocd-cli

# macOS
brew install argocd

# Linux
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```

Verify:
```bash
argocd version --client
```

---

## 🚀 Project Setup

### Step 1: Clone the Repository

**Ubuntu/macOS:**
```bash
git clone https://github.com/your-username/devops-simple-capstone.git
cd devops-simple-capstone
```

**Windows PowerShell:**
```powershell
git clone https://github.com/your-username/devops-simple-capstone.git
cd devops-simple-capstone
```

**Windows Command Prompt:**
```cmd
git clone https://github.com/your-username/devops-simple-capstone.git
cd devops-simple-capstone
```

---

### Step 2: Test Application Locally

**Ubuntu/macOS:**
```bash
cd app
npm install
npm start
```

**Windows PowerShell:**
```powershell
cd app
npm install
npm start
```

**Windows Command Prompt:**
```cmd
cd app
npm install
npm start
```

**Access the application:**
- Ubuntu: Open http://localhost:3000 in browser
- macOS: Open http://localhost:3000 in browser  
- Windows: Open http://localhost:3000 in browser

**Stop the server:**
- All platforms: Press `Ctrl+C`

---

### Step 3: Create Docker Hub Account

1. Go to https://hub.docker.com
2. Sign up for a free account
3. Note your username (you'll need it later)

---

### Step 4: Build and Test Docker Image

**Ubuntu/macOS:**
```bash
# Login to Docker Hub
docker login

# Build the image (from project root)
docker build -t your-dockerhub-username/task-manager:v1.0 -f docker/Dockerfile ./app

# Test the image
docker run -d -p 8080:3000 --name task-manager-test your-dockerhub-username/task-manager:v1.0

# Verify it's running
curl http://localhost:8080/health

# Stop and remove test container
docker stop task-manager-test
docker rm task-manager-test

# Push to Docker Hub
docker push your-dockerhub-username/task-manager:v1.0
```

**Windows PowerShell:**
```powershell
# Login to Docker Hub
docker login

# Build the image (from project root)
docker build -t your-dockerhub-username/task-manager:v1.0 -f docker\Dockerfile .\app

# Test the image
docker run -d -p 8080:3000 --name task-manager-test your-dockerhub-username/task-manager:v1.0

# Verify it's running
Invoke-WebRequest http://localhost:8080/health

# Stop and remove test container
docker stop task-manager-test
docker rm task-manager-test

# Push to Docker Hub
docker push your-dockerhub-username/task-manager:v1.0
```

---

### Step 5: Set Up Local Kubernetes Cluster

**Using Minikube:**
```bash
# Start cluster
minikube start --driver=docker --cpus=2 --memory=4096

# Enable addons
minikube addons enable ingress
minikube addons enable metrics-server

# Verify
kubectl cluster-info
kubectl get nodes
```

**Using Kind:**
```bash
# Create cluster
kind create cluster --name devops-capstone --config=- <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
- role: worker
EOF

# Verify
kubectl cluster-info
kubectl get nodes
```

---

### Step 6: Deploy with Kubectl

**Ubuntu/macOS:**
```bash
# Update image in deployment.yaml first
sed -i 's|your-dockerhub-username|YOUR_ACTUAL_USERNAME|g' kubernetes/deployment.yaml

# Apply manifests
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/ingress.yaml

# Check deployment
kubectl get pods
kubectl get services
kubectl get ingress

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=task-manager --timeout=300s

# Port forward to access
kubectl port-forward svc/task-manager 8080:80
```

**Windows PowerShell:**
```powershell
# Update image in deployment.yaml first (manual edit or use this)
(Get-Content kubernetes\deployment.yaml) -replace 'your-dockerhub-username','YOUR_ACTUAL_USERNAME' | Set-Content kubernetes\deployment.yaml

# Apply manifests
kubectl apply -f kubernetes\deployment.yaml
kubectl apply -f kubernetes\service.yaml
kubectl apply -f kubernetes\ingress.yaml

# Check deployment
kubectl get pods
kubectl get services
kubectl get ingress

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=task-manager --timeout=300s

# Port forward to access
kubectl port-forward svc/task-manager 8080:80
```

**Access the application (all platforms):**
Visit: http://localhost:8080

---

### Step 7: Deploy with Helm

**Ubuntu/macOS:**
```bash
# Update values in helm/task-manager/values.yaml
# Change image.repository to your Docker Hub username

# Install the chart
helm install task-manager ./helm/task-manager -n task-manager --create-namespace

# Check release
helm list -n task-manager

# Check resources
kubectl get all -n task-manager

# Port forward
kubectl port-forward -n task-manager svc/task-manager 8080:80
```

**Windows PowerShell:**
```powershell
# Update values in helm\task-manager\values.yaml
# Change image.repository to your Docker Hub username

# Install the chart
helm install task-manager .\helm\task-manager -n task-manager --create-namespace

# Check release
helm list -n task-manager

# Check resources
kubectl get all -n task-manager

# Port forward
kubectl port-forward -n task-manager svc/task-manager 8080:80
```

**Access the application (all platforms):**
Open http://localhost:8080 in your browser

---

### Step 8: Provision Infrastructure with Terraform

**Ubuntu/macOS:**
```bash
cd terraform

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply configuration
terraform apply -auto-approve

# Save kubeconfig
kind export kubeconfig --name devops-capstone-cluster

# Verify
kubectl cluster-info
kubectl get nodes
kubectl get namespaces
```

**Windows PowerShell:**
```powershell
cd terraform

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply configuration
terraform apply -auto-approve

# Save kubeconfig
kind export kubeconfig --name devops-capstone-cluster

# Verify
kubectl cluster-info
kubectl get nodes
kubectl get namespaces
```

---

### Step 9: Set Up Jenkins

**Option A: Run Jenkins in Docker**

**Ubuntu/macOS:**
```bash
docker run -d -p 8081:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --name jenkins \
  jenkins/jenkins:lts
```

**Windows PowerShell:**
```powershell
docker run -d -p 8081:8080 -p 50000:50000 `
  -v jenkins_home:/var/jenkins_home `
  -v /var/run/docker.sock:/var/run/docker.sock `
  --name jenkins `
  jenkins/jenkins:lts
```

**Access Jenkins (all platforms):**
1. Open http://localhost:8081
2. Get initial admin password:
   
   **Ubuntu/macOS:**
   ```bash
   docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
   ```
   
   **Windows PowerShell:**
   ```powershell
   docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
   ```
3. Install suggested plugins
4. Create admin user

**Configure Jenkins:**
1. Install additional plugins:
   - Docker Pipeline
   - Kubernetes
   - Git
2. Add credentials:
   - Docker Hub credentials (ID: `dockerhub-credentials`)
   - Kubeconfig file (ID: `kubeconfig-credentials`)
3. Create Pipeline:
   - New Item → Pipeline
   - Pipeline script from SCM
   - Git: Your repository URL
   - Script Path: `jenkins/Jenkinsfile`

---

### Step 10: Install ArgoCD

**Ubuntu/macOS:**
```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Expose ArgoCD server
kubectl port-forward svc/argocd-server -n argocd 8082:443

# In a new terminal, get initial password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo  # Print newline

# Login via CLI (optional)
argocd login localhost:8082 --username admin --password <password-from-above> --insecure
```

**Windows PowerShell:**
```powershell
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Expose ArgoCD server (in one PowerShell window)
kubectl port-forward svc/argocd-server -n argocd 8082:443

# In a new PowerShell window, get initial password
$password = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($password))

# Login via CLI (optional)
argocd login localhost:8082 --username admin --password <password-from-above> --insecure
```

**Access ArgoCD UI (all platforms):**
- URL: https://localhost:8082
- Username: admin
- Password: (from command above)
- Note: Accept the self-signed certificate warning

---

### Step 11: Deploy Application with ArgoCD

```bash
# Update argocd/application.yaml with your repository and image

# Apply ArgoCD application
kubectl apply -f argocd/application.yaml

# Check application status
argocd app get task-manager

# Sync application
argocd app sync task-manager

# Watch sync progress
argocd app wait task-manager --health
```

---

## 🔍 Verification Commands

```bash
# Check all resources
kubectl get all -n task-manager

# Check logs
kubectl logs -n task-manager -l app=task-manager

# Check events
kubectl get events -n task-manager

# Describe pod
kubectl describe pod -n task-manager -l app=task-manager

# Test health endpoint
kubectl port-forward -n task-manager svc/task-manager 8080:80
curl http://localhost:8080/health
```

---

## 🧪 Testing the Complete Workflow

### 1. Make a code change
```bash
# Edit app/server.js or app/public/index.html
git add .
git commit -m "Update application"
git push origin main
```

### 2. Jenkins will automatically:
- Build the application
- Create Docker image
- Push to Docker Hub
- Deploy to Kubernetes

### 3. ArgoCD will automatically:
- Detect changes in Git
- Sync application state
- Deploy updates

### 4. Verify the update
```bash
kubectl rollout status deployment/task-manager -n task-manager
kubectl get pods -n task-manager
```

---

## 🎯 Next Steps

1. Configure webhooks for automatic Jenkins builds
2. Set up monitoring with Prometheus and Grafana
3. Implement logging with ELK stack
4. Add automated tests
5. Implement blue-green or canary deployments
6. Set up alerts and notifications

---

## 📚 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [Helm Documentation](https://helm.sh/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Terraform Documentation](https://www.terraform.io/docs/)

---

## ❓ Need Help?

If you encounter issues, refer to:
- [Troubleshooting Guide](docs/troubleshooting.md)
- [Solution Walkthrough](SOLUTION.md)

Good luck! 🚀
