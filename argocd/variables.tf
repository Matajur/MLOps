variable "region" {
  description = "Default AWS region"
  type        = string
  default     = "us-east-1" # Same as in main/variables.tf
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster" # Same as in main/variables.tf
}

variable "argocd_namespace" {
  description = "Namespace for Argo CD"
  type        = string
  default     = "infra-tools"
}
