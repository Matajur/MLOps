variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "vpc_id" {
  type        = string
  description = "VPC id where EKS should be deployed"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs (for node groups)"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes version for the EKS cluster"
}

variable "eks_managed_node_groups" {
  description = "Managed node groups configuration"
  type = map(object({
    min_size       = number
    max_size       = number
    desired_size   = number
    instance_types = list(string)
  }))
}

variable "my_ip_address" {
  type        = string
  description = "Your public IP address for EKS cluster access"
}
