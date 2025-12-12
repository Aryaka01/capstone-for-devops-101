output "cluster_name" {
  description = "Name of the Kubernetes cluster"
  value       = kind_cluster.default.name
}

output "cluster_endpoint" {
  description = "Endpoint for the Kubernetes cluster"
  value       = kind_cluster.default.endpoint
}

output "namespace" {
  description = "Namespace where the application is deployed"
  value       = kubernetes_namespace.task_manager.metadata[0].name
}

output "argocd_server_url" {
  description = "ArgoCD server URL"
  value       = "https://localhost:30443"
}

output "argocd_initial_admin_password_command" {
  description = "Command to retrieve ArgoCD initial admin password"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

output "kubeconfig_path" {
  description = "Path to save the kubeconfig file"
  value       = "${path.cwd}/kubeconfig"
}

output "next_steps" {
  description = "Next steps after infrastructure provisioning"
  value = <<-EOT
    
    ✅ Infrastructure provisioned successfully!
    
    Next steps:
    1. Export kubeconfig:
       export KUBECONFIG=${path.cwd}/kubeconfig
    
    2. Verify cluster:
       kubectl cluster-info
       kubectl get nodes
    
    3. Access ArgoCD:
       URL: https://localhost:30443
       Username: admin
       Password: Run the command from 'argocd_initial_admin_password_command' output
    
    4. Deploy application:
       kubectl apply -f ../kubernetes/
       OR
       helm install task-manager ../helm/task-manager -n ${kubernetes_namespace.task_manager.metadata[0].name}
    
    5. Access application:
       kubectl port-forward -n ${kubernetes_namespace.task_manager.metadata[0].name} svc/task-manager 8080:80
       Visit: http://localhost:8080
  EOT
}
