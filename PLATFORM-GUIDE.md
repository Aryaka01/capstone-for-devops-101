# Platform-Specific Command Reference

Quick reference guide for running commands on different operating systems.

---

## 🖥️ Your Operating System

### Which Commands Should I Use?

- **Windows users:** Use the **Windows PowerShell** commands
- **macOS users:** Use the **Ubuntu/macOS** commands
- **Linux users:** Use the **Ubuntu/macOS** commands

---

## 📋 Common Command Differences

### 1. File Paths

**Ubuntu/macOS:**
```bash
cd app
kubectl apply -f kubernetes/deployment.yaml
docker build -f docker/Dockerfile .
```

**Windows PowerShell:**
```powershell
cd app
kubectl apply -f kubernetes\deployment.yaml
docker build -f docker\Dockerfile .
```

**Rule:** Use `/` on Linux/Mac, use `\` on Windows PowerShell

---

### 2. Line Continuation

**Ubuntu/macOS:**
```bash
docker run -d \
  -p 8080:3000 \
  --name myapp \
  myimage:latest
```

**Windows PowerShell:**
```powershell
docker run -d `
  -p 8080:3000 `
  --name myapp `
  myimage:latest
```

**Rule:** Use `\` on Linux/Mac, use `` ` `` (backtick) on Windows PowerShell

---

### 3. Opening Web Browser

**Ubuntu:**
```bash
xdg-open http://localhost:8080
```

**macOS:**
```bash
open http://localhost:8080
```

**Windows PowerShell:**
```powershell
Start-Process http://localhost:8080
```

**Or just manually open your browser and go to:** http://localhost:8080

---

### 4. Making HTTP Requests

**Ubuntu/macOS:**
```bash
curl http://localhost:8080/health
curl -X POST http://localhost:8080/api/tasks -H "Content-Type: application/json" -d '{"title":"Test"}'
```

**Windows PowerShell:**
```powershell
Invoke-WebRequest http://localhost:8080/health
Invoke-WebRequest -Method POST -Uri http://localhost:8080/api/tasks -ContentType "application/json" -Body '{"title":"Test"}'
```

---

### 5. Environment Variables

**Ubuntu/macOS:**
```bash
export DOCKER_USER="myusername"
echo $DOCKER_USER
```

**Windows PowerShell:**
```powershell
$env:DOCKER_USER="myusername"
echo $env:DOCKER_USER
```

---

### 6. Text File Editing (Find and Replace)

**Ubuntu/macOS:**
```bash
sed -i 's|old-text|new-text|g' filename.yaml
```

**macOS (some versions):**
```bash
sed -i '' 's|old-text|new-text|g' filename.yaml
```

**Windows PowerShell:**
```powershell
(Get-Content filename.yaml) -replace 'old-text','new-text' | Set-Content filename.yaml
```

---

### 7. Deleting Files and Folders

**Ubuntu/macOS:**
```bash
rm -rf folder_name
rm file.txt
```

**Windows PowerShell:**
```powershell
Remove-Item -Recurse -Force folder_name
Remove-Item file.txt
```

---

### 8. Listing Files

**Ubuntu/macOS:**
```bash
ls -la
ls -lh
```

**Windows PowerShell:**
```powershell
Get-ChildItem
ls  # PowerShell alias for Get-ChildItem
dir # Also works in PowerShell
```

---

### 9. Finding Process Using Port

**Ubuntu/Linux:**
```bash
lsof -ti:3000 | xargs kill -9
# Or
sudo fuser -k 3000/tcp
```

**macOS:**
```bash
lsof -ti:3000 | xargs kill -9
```

**Windows PowerShell:**
```powershell
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

---

### 10. Base64 Decoding

**Ubuntu/macOS:**
```bash
echo "SGVsbG8gV29ybGQ=" | base64 -d
# Or
kubectl get secret my-secret -o jsonpath="{.data.password}" | base64 -d
```

**Windows PowerShell:**
```powershell
$encoded = "SGVsbG8gV29ybGQ="
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encoded))
# Or for Kubernetes secrets
$password = kubectl get secret my-secret -o jsonpath="{.data.password}"
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($password))
```

---

## ✅ Commands That Are the Same on All Platforms

These commands work identically on Ubuntu, macOS, and Windows:

### Docker Commands
```bash
docker ps
docker images
docker build -t myapp:v1.0 .
docker run -d -p 8080:3000 myapp:v1.0
docker logs container_name
docker stop container_name
docker rm container_name
docker push myimage:tag
docker pull myimage:tag
```

### Kubernetes (kubectl) Commands
```bash
kubectl get pods
kubectl get services
kubectl get deployments
kubectl apply -f manifest.yaml
kubectl delete -f manifest.yaml
kubectl describe pod pod-name
kubectl logs pod-name
kubectl port-forward svc/myservice 8080:80
kubectl exec -it pod-name -- /bin/sh
```

### Helm Commands
```bash
helm install myapp ./chart
helm upgrade myapp ./chart
helm list
helm rollback myapp
helm uninstall myapp
```

### Terraform Commands
```bash
terraform init
terraform plan
terraform apply
terraform destroy
terraform validate
terraform fmt
```

### Git Commands
```bash
git clone https://github.com/user/repo.git
git add .
git commit -m "message"
git push origin main
git pull
git status
git log
git branch
```

### Node.js/NPM Commands
```bash
npm install
npm start
npm test
npm run build
node --version
npm --version
```

---

## 🎯 Quick Tips

### For Windows Users:

1. **Use PowerShell, not CMD** - PowerShell is more powerful and similar to bash
2. **Install Windows Terminal** - Better terminal experience (optional)
3. **Use WSL2 if needed** - For true Linux experience (optional, not required)
4. **Copy-paste carefully** - Watch out for path separators

### For macOS Users:

1. **Use Terminal app** - Built-in terminal works great
2. **Install Homebrew** - Package manager for macOS tools
3. **Use zsh or bash** - Both work well (zsh is default on newer macOS)
4. **Some sed commands** - May need `sed -i ''` instead of `sed -i`

### For Ubuntu/Linux Users:

1. **Use bash** - Default and recommended
2. **sudo for permissions** - Some Docker commands may need sudo
3. **apt package manager** - For installing tools

---

## 🔧 Tool-Specific Installation

### Installing Tools on Different Platforms

#### Git

**Ubuntu:**
```bash
sudo apt-get update
sudo apt-get install -y git
```

**macOS:**
```bash
brew install git
```

**Windows:**
```powershell
winget install Git.Git
# Or
choco install git
```

#### Docker Desktop

- **All platforms:** Download from https://www.docker.com/products/docker-desktop/
- Comes with Docker, kubectl, and Kubernetes

#### kubectl

**Ubuntu:**
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

**macOS:**
```bash
brew install kubectl
```

**Windows:**
```powershell
winget install Kubernetes.kubectl
# Or
choco install kubernetes-cli
```

#### Helm

**Ubuntu:**
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

**macOS:**
```bash
brew install helm
```

**Windows:**
```powershell
winget install Helm.Helm
# Or
choco install kubernetes-helm
```

#### Terraform

**Ubuntu:**
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

**macOS:**
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

**Windows:**
```powershell
winget install Hashicorp.Terraform
# Or
choco install terraform
```

---

## ❓ FAQ

### Q: Why are the commands different?

**A:** Different operating systems have different:
- File path conventions (/ vs \)
- Shell syntax (bash vs PowerShell)
- Built-in utilities (curl vs Invoke-WebRequest)

### Q: Can I use WSL (Windows Subsystem for Linux) instead?

**A:** Yes! WSL2 gives you a real Linux environment on Windows. If you use WSL, follow the **Ubuntu/macOS** commands.

### Q: Do I need to know both?

**A:** No! Just use the commands for your operating system. The concepts are the same.

### Q: What if a command doesn't work?

**A:** 
1. Check you're using the right version (Windows PowerShell vs Ubuntu/macOS)
2. Check for typos (especially path separators)
3. See [troubleshooting.md](docs/troubleshooting.md)
4. Ask for help in GitHub Issues

### Q: Can I mix commands from different platforms?

**A:** No! Use all commands from your platform section. Mixing may cause errors.

---

## 🎓 Learning Resources

### For Windows Users New to PowerShell:
- [PowerShell 101](https://docs.microsoft.com/en-us/powershell/scripting/learn/ps101/01-getting-started)
- [PowerShell for Linux Users](https://docs.microsoft.com/en-us/powershell/scripting/learn/ps101/00-introduction)

### For macOS/Linux Users:
- [Bash Guide](https://www.gnu.org/software/bash/manual/bash.html)
- [Linux Command Line Basics](https://ubuntu.com/tutorials/command-line-for-beginners)

---

## ✅ Verification Commands

Test your environment (same on all platforms):

```bash
# Check versions
git --version
docker --version
kubectl version --client
helm version
terraform --version
node --version
npm --version

# Check Docker is running
docker ps

# Check Kubernetes
kubectl cluster-info
```

---

**Remember:** The DevOps concepts are the same regardless of your platform. The commands are just the "language" you use to talk to the tools!

**Need help?** Check the [troubleshooting guide](docs/troubleshooting.md) or open an issue!
