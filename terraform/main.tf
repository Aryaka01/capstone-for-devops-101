# Terraform Configuration for Local Kubernetes Cluster
# This example uses Kind (Kubernetes in Docker) for local development

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

# Create Kind cluster
resource "kind_cluster" "default" {
  name           = var.cluster_name
  wait_for_ready = true
  
  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"
    
    node {
      role = "control-plane"
      
      kubeadm_config_patches = [
        "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
      ]
      
      extra_port_mappings {
        container_port = 80
        host_port      = 80
        protocol       = "TCP"
      }
      
      extra_port_mappings {
        container_port = 443
        host_port      = 443
        protocol       = "TCP"
      }
    }
    
    node {
      role = "worker"
    }
    
    node {
      role = "worker"
    }
  }
}

# Configure Kubernetes provider
provider "kubernetes" {
  host                   = kind_cluster.default.endpoint
  cluster_ca_certificate = kind_cluster.default.cluster_ca_certificate
  client_certificate     = kind_cluster.default.client_certificate
  client_key             = kind_cluster.default.client_key
}

# Configure Helm provider
provider "helm" {
  kubernetes {
    host                   = kind_cluster.default.endpoint
    cluster_ca_certificate = kind_cluster.default.cluster_ca_certificate
    client_certificate     = kind_cluster.default.client_certificate
    client_key             = kind_cluster.default.client_key
  }
}

# Create namespace for the application
resource "kubernetes_namespace" "task_manager" {
  metadata {
    name = var.namespace
    labels = {
      name        = var.namespace
      environment = var.environment
    }
  }
  
  depends_on = [kind_cluster.default]
}

# Install NGINX Ingress Controller
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  
  create_namespace = true
  
  set {
    name  = "controller.service.type"
    value = "NodePort"
  }
  
  set {
    name  = "controller.hostPort.enabled"
    value = "true"
  }
  
  depends_on = [kind_cluster.default]
}

# Install ArgoCD
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "5.51.0"
  
  create_namespace = true
  
  set {
    name  = "server.service.type"
    value = "NodePort"
  }
  
  set {
    name  = "server.service.nodePortHttp"
    value = "30080"
  }
  
  set {
    name  = "server.service.nodePortHttps"
    value = "30443"
  }
  
  depends_on = [kind_cluster.default]
}

# Create ConfigMap for application configuration
resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "task-manager-config"
    namespace = kubernetes_namespace.task_manager.metadata[0].name
  }
  
  data = {
    NODE_ENV = var.environment
    PORT     = "3000"
  }
}

# Output cluster information
output "cluster_name" {
  description = "Name of the Kind cluster"
  value       = kind_cluster.default.name
}

output "kubeconfig" {
  description = "Kubeconfig for accessing the cluster"
  value       = kind_cluster.default.kubeconfig
  sensitive   = true
}

output "cluster_endpoint" {
  description = "Kubernetes cluster endpoint"
  value       = kind_cluster.default.endpoint
}

output "namespace" {
  description = "Application namespace"
  value       = kubernetes_namespace.task_manager.metadata[0].name
}
