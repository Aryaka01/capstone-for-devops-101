# Troubleshooting Guide - DevOps Capstone Project

Common issues and their solutions.

---

## 🐛 Application Issues

### Issue 1: Application Not Starting Locally

**Symptoms:**
```
npm start
Error: Cannot find module 'express'
```

**Solution:**

**Ubuntu/macOS:**
```bash
cd app
rm -rf node_modules package-lock.json
npm install
npm start
```

**Windows PowerShell:**
```powershell
cd app
Remove-Item -Recurse -Force node_modules, package-lock.json
npm install
npm start
```

**Prevention:**
- Always run `npm install` after cloning
- Check Node.js version: `node --version` (should be >= 18.0.0)

---

### Issue 2: Port Already in Use

**Symptoms:**
```
Error: listen EADDRINUSE: address already in use :::3000
```

**Solution:**

**Windows PowerShell:**
```powershell
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

**macOS:**
```bash
lsof -ti:3000 | xargs kill -9
```

**Ubuntu/Linux:**
```bash
lsof -ti:3000 | xargs kill -9
# Or using fuser
sudo fuser -k 3000/tcp
```

**Alternative (all platforms):**
```bash
# Use different port
PORT=3001 npm start
```

---

## 🐳 Docker Issues

### Issue 3: Docker Build Fails

**Symptoms:**
```
ERROR [internal] load metadata for docker.io/library/node:18-alpine
```

**Solutions:**

1. **Check Docker is running (all platforms):**
   ```bash
   docker ps
   ```

2. **Login to Docker Hub (all platforms):**
   ```bash
   docker login
   ```

3. **Pull base image manually (all platforms):**
   ```bash
   docker pull node:18-alpine
   ```

4. **Clear Docker cache:**
   
   **All platforms:**
   ```bash
   docker system prune -a
   ```

---

### Issue 4: Permission Denied (Docker)

**Symptoms:**
```
permission denied while trying to connect to Docker daemon socket
```

**Solutions:**

**Linux:**
```bash
sudo usermod -aG docker $USER
newgrp docker
# Or logout and login again
```

**Windows:**
- Ensure Docker Desktop is running
- Run PowerShell/CMD as Administrator

---

### Issue 5: Image Push Fails

**Symptoms:**
```
denied: requested access to the resource is denied
```

**Solutions:**

1. **Login to Docker Hub (all platforms):**
   ```bash
   docker login
   ```

2. **Check image name format:**
   
   **Ubuntu/macOS:**
   ```bash
   # Must be: dockerhub-username/image-name:tag
   docker tag task-manager:v1.0 your-username/task-manager:v1.0
   docker push your-username/task-manager:v1.0
   ```
   
   **Windows PowerShell:**
   ```powershell
   # Must be: dockerhub-username/image-name:tag
   docker tag task-manager:v1.0 your-username/task-manager:v1.0
   docker push your-username/task-manager:v1.0
   ```

3. **Verify repository exists:**
   - Go to https://hub.docker.com
   - Check repository is created

---

## ☸️ Kubernetes Issues

### Issue 6: ImagePullBackOff

**Symptoms:**
```bash
kubectl get pods
NAME                            READY   STATUS             RESTARTS   AGE
task-manager-5d4f8c7b6d-x7k9p   0/1     ImagePullBackOff   0          2m
```

**Diagnosis (all platforms):**
```bash
kubectl describe pod <pod-name>
```

**Solutions:**

1. **Check image exists (all platforms):**
   ```bash
   docker pull your-username/task-manager:latest
   ```

2. **Update image reference:**
   
   **Ubuntu/macOS:**
   ```bash
   # Update deployment.yaml
   sed -i 's|your-dockerhub-username|ACTUAL_USERNAME|g' kubernetes/deployment.yaml
   kubectl apply -f kubernetes/deployment.yaml
   ```
   
   **Windows PowerShell:**
   ```powershell
   # Update deployment.yaml
   (Get-Content kubernetes\deployment.yaml) -replace 'your-dockerhub-username','ACTUAL_USERNAME' | Set-Content kubernetes\deployment.yaml
   kubectl apply -f kubernetes\deployment.yaml
   ```
   ```

2. **Correct image name in deployment:**
   ```bash
   kubectl edit deployment task-manager
   # Fix image: line
   ```

3. **Add image pull secret (if private):**
   ```bash
   kubectl create secret docker-registry regcred \
     --docker-server=docker.io \
     --docker-username=YOUR_USERNAME \
     --docker-password=YOUR_PASSWORD \
     --docker-email=YOUR_EMAIL
   
   # Add to deployment:
   spec:
     imagePullSecrets:
     - name: regcred
   ```

---

### Issue 7: CrashLoopBackOff

**Symptoms:**
```bash
kubectl get pods
NAME                            READY   STATUS             RESTARTS   AGE
task-manager-5d4f8c7b6d-x7k9p   0/1     CrashLoopBackOff   5          5m
```

**Diagnosis:**
```bash
# Check logs
kubectl logs <pod-name>
kubectl logs <pod-name> --previous

# Check events
kubectl describe pod <pod-name>
```

**Common Causes & Solutions:**

1. **Application error:**
   ```bash
   # Check logs for error messages
   kubectl logs <pod-name>
   # Test image locally
   docker run -it your-username/task-manager:latest
   ```

2. **Missing dependencies:**
   ```bash
   # Rebuild image with proper npm install
   docker build --no-cache -t your-username/task-manager:latest .
   ```

3. **Health check failing:**
   ```yaml
   # Increase initialDelaySeconds in deployment.yaml
   livenessProbe:
     initialDelaySeconds: 60  # Increase from 30
   ```

---

### Issue 8: Pods Pending

**Symptoms:**
```bash
kubectl get pods
NAME                            READY   STATUS    RESTARTS   AGE
task-manager-5d4f8c7b6d-x7k9p   0/1     Pending   0          10m
```

**Diagnosis:**
```bash
kubectl describe pod <pod-name>
```

**Solutions:**

1. **Insufficient resources:**
   ```bash
   # Check node resources
   kubectl describe nodes
   
   # Reduce resource requests
   kubectl edit deployment task-manager
   # Lower resources.requests values
   ```

2. **No nodes available:**
   ```bash
   kubectl get nodes
   # If no nodes, cluster not started
   minikube start
   # OR
   kind create cluster
   ```

---

### Issue 9: Service Not Accessible

**Symptoms:**
```bash
curl http://localhost:8080
curl: (7) Failed to connect to localhost port 8080
```

**Solutions:**

1. **Check service exists:**
   ```bash
   kubectl get svc task-manager
   ```

2. **Check port-forward:**
   ```bash
   # Kill existing port-forward
   pkill -f "port-forward"
   
   # Start new port-forward
   kubectl port-forward svc/task-manager 8080:80
   ```

3. **Check pods are running:**
   ```bash
   kubectl get pods -l app=task-manager
   # All should be Running and Ready
   ```

4. **Test from within cluster:**
   ```bash
   kubectl run -it --rm debug --image=busybox --restart=Never -- sh
   # Inside pod:
   wget -O- http://task-manager/health
   ```

---

## 🎡 Helm Issues

### Issue 10: Helm Install Fails

**Symptoms:**
```
Error: rendered manifests contain a resource that already exists
```

**Solutions:**

1. **Release already exists:**
   ```bash
   helm list -A
   helm uninstall task-manager -n task-manager
   helm install task-manager ./helm/task-manager -n task-manager
   ```

2. **Resources exist from kubectl:**
   ```bash
   kubectl delete all -l app=task-manager
   helm install task-manager ./helm/task-manager
   ```

---

### Issue 11: Helm Template Error

**Symptoms:**
```
Error: parse error at (task-manager/templates/deployment.yaml:10)
```

**Solutions:**

1. **Validate template:**
   ```bash
   helm template task-manager ./helm/task-manager --debug
   ```

2. **Check syntax:**
   ```bash
   helm lint ./helm/task-manager
   ```

3. **Common issues:**
   - Missing closing brackets: `}}`
   - Wrong indentation in YAML
   - Undefined values: check `values.yaml`

---

## 🏗️ Terraform Issues

### Issue 12: Terraform Init Fails

**Symptoms:**
```
Error: Failed to query available provider packages
```

**Solutions:**

1. **Check internet connection**

2. **Clear Terraform cache:**
   ```bash
   rm -rf .terraform .terraform.lock.hcl
   terraform init
   ```

3. **Use specific provider versions:**
   ```hcl
   terraform {
     required_providers {
       kind = {
         source  = "tehcyx/kind"
         version = "0.2.1"  # Specific version
       }
     }
   }
   ```

---

### Issue 13: Terraform Apply Fails

**Symptoms:**
```
Error: error creating kind cluster: node(s) already exist for a cluster with the name
```

**Solutions:**

1. **Delete existing cluster:**
   ```bash
   kind delete cluster --name devops-capstone-cluster
   terraform apply
   ```

2. **Import existing resources:**
   ```bash
   terraform import kind_cluster.default devops-capstone-cluster
   ```

---

## 🔄 Jenkins Issues

### Issue 14: Jenkins Build Fails - Docker Permission

**Symptoms:**
```
Got permission denied while trying to connect to Docker daemon socket
```

**Solutions:**

1. **Add Jenkins user to docker group:**
   ```bash
   docker exec -u root jenkins bash -c "usermod -aG docker jenkins"
   docker restart jenkins
   ```

2. **Or mount Docker socket:**
   ```bash
   docker run -d \
     -v /var/run/docker.sock:/var/run/docker.sock \
     -v jenkins_home:/var/jenkins_home \
     -p 8081:8080 \
     --name jenkins \
     jenkins/jenkins:lts
   ```

---

### Issue 15: Jenkins Can't Connect to Kubernetes

**Symptoms:**
```
ERROR: Unable to connect to Kubernetes cluster
```

**Solutions:**

1. **Add kubeconfig credential:**
   - Jenkins → Credentials → Add
   - Kind: Secret file
   - File: your kubeconfig
   - ID: kubeconfig-credentials

2. **Test connection:**
   ```groovy
   withCredentials([file(credentialsId: 'kubeconfig-credentials', variable: 'KUBECONFIG')]) {
       sh 'kubectl cluster-info'
   }
   ```

---

## 🔱 ArgoCD Issues

### Issue 16: ArgoCD Application Not Syncing

**Symptoms:**
```
Application health: Degraded
Sync status: OutOfSync
```

**Solutions:**

1. **Check application details:**
   ```bash
   argocd app get task-manager
   ```

2. **Force sync:**
   ```bash
   argocd app sync task-manager --force
   ```

3. **Check Git repository access:**
   ```bash
   argocd repo list
   # If private repo, add credentials
   argocd repo add https://github.com/user/repo.git --username user --password token
   ```

4. **Check target namespace exists:**
   ```bash
   kubectl get namespace task-manager
   # If not exists:
   kubectl create namespace task-manager
   ```

---

### Issue 17: Can't Access ArgoCD UI

**Symptoms:**
```
Unable to connect to localhost:8082
```

**Solutions:**

1. **Check port-forward is running:**
   ```bash
   ps aux | grep port-forward
   # If not running:
   kubectl port-forward svc/argocd-server -n argocd 8082:443
   ```

2. **Check ArgoCD pods:**
   ```bash
   kubectl get pods -n argocd
   # All should be Running
   ```

3. **Access via NodePort (alternative):**
   ```bash
   kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
   kubectl get svc argocd-server -n argocd
   # Access via NodePort
   ```

---

## 🌐 Networking Issues

### Issue 18: Ingress Not Working

**Symptoms:**
```
curl: (7) Failed to connect to task-manager.local
```

**Solutions:**

1. **Check Ingress Controller installed:**
   ```bash
   kubectl get pods -n ingress-nginx
   # OR for Minikube:
   minikube addons enable ingress
   ```

2. **Add hosts entry:**
   
   **Linux/macOS:**
   ```bash
   echo "127.0.0.1 task-manager.local" | sudo tee -a /etc/hosts
   ```
   
   **Windows (as Administrator):**
   ```powershell
   Add-Content C:\Windows\System32\drivers\etc\hosts "127.0.0.1 task-manager.local"
   ```

3. **Port forward ingress controller:**
   ```bash
   kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80
   # Then access: http://localhost:8080
   ```

---

## 🔐 Authentication Issues

### Issue 19: Docker Login Fails

**Solutions:**

```bash
# Clear credentials
rm ~/.docker/config.json

# Login again
docker login

# If using access token:
docker login -u USERNAME -p ACCESS_TOKEN
```

---

### Issue 20: kubectl Unauthorized

**Symptoms:**
```
Error from server (Forbidden): pods is forbidden
```

**Solutions:**

1. **Check kubeconfig:**
   ```bash
   kubectl config current-context
   kubectl config use-context <correct-context>
   ```

2. **Update kubeconfig:**
   ```bash
   # Minikube:
   minikube update-context
   
   # Kind:
   kind export kubeconfig --name devops-capstone
   ```

---

## 📊 Performance Issues

### Issue 21: Application Running Slow

**Solutions:**

1. **Check resource limits:**
   ```bash
   kubectl top pods -n task-manager
   kubectl describe pod <pod-name> -n task-manager
   ```

2. **Increase resources:**
   ```bash
   kubectl edit deployment task-manager -n task-manager
   # Increase limits
   ```

3. **Scale up:**
   ```bash
   kubectl scale deployment task-manager --replicas=5 -n task-manager
   ```

---

## 🛠️ General Debugging Tips

### Essential Commands

```bash
# Check everything
kubectl get all -n task-manager

# Detailed pod info
kubectl describe pod <pod-name> -n task-manager

# Logs
kubectl logs <pod-name> -n task-manager
kubectl logs <pod-name> -n task-manager --previous
kubectl logs -l app=task-manager -n task-manager --tail=100

# Events
kubectl get events -n task-manager --sort-by='.lastTimestamp'

# Shell into pod
kubectl exec -it <pod-name> -n task-manager -- sh

# Check resources
kubectl top nodes
kubectl top pods -n task-manager

# Port forward for testing
kubectl port-forward <pod-name> -n task-manager 8080:3000
```

### Debug Container

```bash
# Run debug container in cluster
kubectl run -it --rm debug --image=busybox --restart=Never -- sh

# Inside debug container:
wget -O- http://task-manager.task-manager.svc.cluster.local/health
nslookup task-manager.task-manager.svc.cluster.local
```

---

## 📞 Getting Help

If issues persist:

1. **Check logs carefully** - Most issues show clear error messages
2. **Google the error message** - Likely someone else had the same issue
3. **Check GitHub Issues** - Look for similar problems
4. **Ask for help** - Provide:
   - Full error message
   - Steps to reproduce
   - Output of diagnostic commands
   - Your environment details

---

## ✅ Prevention Checklist

Before starting, ensure:
- [ ] Docker is running
- [ ] kubectl is configured
- [ ] Kubernetes cluster is running
- [ ] Required tools are installed
- [ ] You have internet connection
- [ ] Sufficient disk space (>10GB free)
- [ ] Sufficient RAM (>4GB free)

---

**Still stuck?** Check the [Solution Walkthrough](../SOLUTION.md) for detailed explanations.
