# DevOps Capstone Project: Full-Stack Application Deployment Pipeline

## 🎯 Project Overview

This capstone project demonstrates a complete DevOps workflow by deploying a simple web application using modern DevOps tools and practices. You'll build an end-to-end CI/CD pipeline that automates the entire software delivery lifecycle.

### **Application**: Simple Task Manager Web App
A lightweight Node.js application with a web interface for managing tasks.

---

## 🏗️ Architecture Diagram

```
Developer → Git/GitHub → Jenkins (CI/CD) → Docker Registry
                              ↓
                         Docker Build
                              ↓
                    Kubernetes Cluster (Terraform)
                              ↓
                         ArgoCD (GitOps)
                              ↓
                         Helm Deployment
                              ↓
                    Running Application (Pods, Services, Ingress)
```

---

## 📚 Learning Objectives

By completing this project, you will:

1. **Git & GitHub**: Manage source code with version control and branching strategies
2. **Docker**: Containerize a web application
3. **Kubernetes**: Deploy and manage containerized applications
4. **Jenkins**: Build automated CI/CD pipelines
5. **ArgoCD**: Implement GitOps deployment practices
6. **Helm**: Package and deploy applications using Helm charts
7. **Terraform**: Provision infrastructure as code
8. **🎁 BONUS**: Monitor applications with Prometheus & Grafana (optional)

---

## 🛠️ Prerequisites

### Required Tools
- Git and GitHub account
- Docker Desktop
- kubectl (Kubernetes CLI)
- Minikube or Kind (local Kubernetes cluster)
- Jenkins (local or cloud instance)
- Helm 3.x
- Terraform
- ArgoCD CLI
- Node.js (for local testing)

### Knowledge Requirements
- Basic understanding of Linux commands
- Familiarity with YAML syntax
- Basic networking concepts
- Understanding of containerization

---

## 📋 Project Structure

```
devops-simple-capstone/
├── README.md                          # This file
├── SOLUTION.md                        # Complete solution walkthrough
├── SETUP-GUIDE.md                     # Detailed setup instructions
├── app/                               # Application source code
│   ├── server.js                      # Node.js backend
│   ├── package.json                   # Node dependencies
│   ├── public/                        # Frontend files
│   │   └── index.html                 # Web interface
│   └── .dockerignore                  # Docker ignore file
├── docker/                            # Docker configuration
│   └── Dockerfile                     # Container image definition
├── kubernetes/                        # Kubernetes manifests
│   ├── deployment.yaml                # Deployment configuration
│   ├── service.yaml                   # Service configuration
│   └── ingress.yaml                   # Ingress configuration
├── helm/                              # Helm chart
│   └── task-manager/                  # Chart directory
│       ├── Chart.yaml                 # Chart metadata
│       ├── values.yaml                # Default values
│       └── templates/                 # Kubernetes templates
│           ├── deployment.yaml
│           ├── service.yaml
│           └── ingress.yaml
├── jenkins/                           # Jenkins configuration
│   └── Jenkinsfile                    # Pipeline definition
├── terraform/                         # Infrastructure as Code
│   ├── main.tf                        # Main configuration
│   ├── variables.tf                   # Variable definitions
│   ├── outputs.tf                     # Output definitions
│   └── provider.tf                    # Provider configuration
├── argocd/                            # ArgoCD configuration
│   └── application.yaml               # Application manifest
└── docs/                              # Additional documentation
    ├── deployment-steps.md            # Step-by-step deployment
    └── troubleshooting.md             # Common issues and solutions
```

---

## 🚀 Implementation Phases

### **Phase 1: Application Development & Containerization** (Day 1-2)
1. Clone the repository
2. Understand the application code
3. Test the application locally
4. Build Docker image
5. Test container locally
6. Push image to Docker Hub

### **Phase 2: Kubernetes Deployment** (Day 3-4)
1. Set up local Kubernetes cluster (Minikube/Kind)
2. Create Kubernetes manifests
3. Deploy application using kubectl
4. Test application access
5. Implement health checks

### **Phase 3: Helm Chart Creation** (Day 5)
1. Convert Kubernetes manifests to Helm chart
2. Configure values for different environments
3. Deploy using Helm
4. Test Helm upgrade and rollback

### **Phase 4: Infrastructure Provisioning with Terraform** (Day 6)
1. Write Terraform configuration
2. Initialize Terraform
3. Plan and apply infrastructure
4. Manage state files

### **Phase 5: CI/CD with Jenkins** (Day 7-8)
1. Set up Jenkins
2. Create Jenkins pipeline
3. Configure webhooks
4. Implement automated builds
5. Integrate Docker builds
6. Deploy to Kubernetes

### **Phase 6: GitOps with ArgoCD** (Day 9)
1. Install ArgoCD
2. Connect to Git repository
3. Create ArgoCD application
4. Configure automated sync
5. Test GitOps workflow

### **Phase 7: Integration & Testing** (Day 10)
1. End-to-end workflow testing
2. Make code changes and observe automation
3. Perform rollbacks
4. Monitor deployments
5. Document findings

---

## 🎯 Project Deliverables

### Required Outputs

1. **GitHub Repository**
   - All source code and configuration files
   - Proper commit history
   - README documentation

2. **Docker Image**
   - Successfully built and tagged image
   - Published to Docker Hub/Registry

3. **Kubernetes Deployment**
   - Running application in K8s cluster
   - Proper services and ingress configured

4. **Helm Chart**
   - Packaged application chart
   - Multiple environment configurations

5. **Terraform Infrastructure**
   - IaC for cluster setup
   - State management

6. **Jenkins Pipeline**
   - Working CI/CD pipeline
   - Automated build and deployment

7. **ArgoCD Configuration**
   - GitOps deployment setup
   - Automated synchronization

8. **Documentation**
   - Architecture diagrams
   - Deployment instructions
   - Troubleshooting guide

---

## 📝 Evaluation Criteria

| Criteria | Points | Description |
|----------|--------|-------------|
| Git Usage | 10 | Proper commits, branches, and GitHub workflow |
| Docker | 15 | Optimized Dockerfile, successful build |
| Kubernetes | 20 | Proper manifests, working deployment |
| Helm | 15 | Well-structured chart, parameterization |
| Terraform | 15 | Valid IaC, successful provisioning |
| Jenkins | 15 | Complete CI/CD pipeline |
| ArgoCD | 10 | GitOps implementation |
| **Total** | **100** | |

---

## 🔗 Quick Start

**Ubuntu/macOS:**
```bash
# Clone the repository
git clone https://github.com/your-username/devops-simple-capstone.git
cd devops-simple-capstone

# Test application locally
cd app
npm install
npm start

# Build Docker image (from project root)
cd ..
docker build -t task-manager:v1.0 -f docker/Dockerfile ./app

# Deploy to Kubernetes
kubectl apply -f kubernetes/

# Deploy with Helm
helm install task-manager ./helm/task-manager

# Access the application
kubectl port-forward svc/task-manager 8080:80
```

**Windows PowerShell:**
```powershell
# Clone the repository
git clone https://github.com/your-username/devops-simple-capstone.git
cd devops-simple-capstone

# Test application locally
cd app
npm install
npm start

# Build Docker image (from project root)
cd ..
docker build -t task-manager:v1.0 -f docker\Dockerfile .\app

# Deploy to Kubernetes
kubectl apply -f kubernetes\

# Deploy with Helm
helm install task-manager .\helm\task-manager

# Access the application
kubectl port-forward svc/task-manager 8080:80
```

Visit `http://localhost:8080` in your browser.

---

## 📖 Additional Resources

- [Setup Guide](SETUP-GUIDE.md) - Detailed environment setup
- [Platform Guide](PLATFORM-GUIDE.md) - **NEW!** Windows/macOS/Ubuntu command reference
- [Solution Walkthrough](SOLUTION.md) - Step-by-step solution
- [Deployment Steps](docs/deployment-steps.md) - Detailed deployment instructions
- [Troubleshooting](docs/troubleshooting.md) - Common issues and fixes
- **🎁 [BONUS: Monitoring with Prometheus & Grafana](BONUS-MONITORING.md)** - Optional advanced exercise (+10 points)

---

## 🤝 Support & Collaboration

- **Questions?** Open an issue in the repository
- **Improvements?** Submit a pull request
- **Discussion?** Use GitHub Discussions

---

## 📜 License

This project is created for educational purposes.

---

## 🎓 Certification

Upon successful completion and presentation of this project, you will have demonstrated proficiency in:
- Modern DevOps practices
- CI/CD pipeline implementation
- Container orchestration
- Infrastructure as Code
- GitOps methodology

**Good luck with your capstone project! 🚀**
