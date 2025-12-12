variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "devops-capstone-cluster"
}

variable "namespace" {
  description = "Kubernetes namespace for the application"
  type        = string
  default     = "task-manager"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "replicas" {
  description = "Number of application replicas"
  type        = number
  default     = 3
  
  validation {
    condition     = var.replicas >= 1 && var.replicas <= 10
    error_message = "Replicas must be between 1 and 10."
  }
}
