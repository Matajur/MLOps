output "vpc_id" {
  description = "VPC id"
  value       = module.this_vpc.vpc_id
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.this_vpc.public_subnets
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.this_vpc.private_subnets
}
