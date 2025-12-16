output "cluster_id" {
  description = "EKS cluster id"
  value       = module.this_eks.cluster_id
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.this_eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group for the cluster control plane"
  value       = module.this_eks.cluster_security_group_id
}
