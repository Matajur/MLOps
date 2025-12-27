# discover AZs in region and pick first N
# region is inherited from the provider
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "./modules/vpc"

  name         = var.vpc_name
  cluster_name = var.cluster_name

  vpc_cidr    = var.vpc_cidr
  azs         = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  subnet_bits = var.public_subnet_suffix_bits
}

locals {
  node_group_count = 1

  # Generate N identical managed node groups
  eks_managed_node_groups = {
    for i in range(local.node_group_count) :
    "ng-${i + 1}" => {
      min_size       = 4
      desired_size   = 4
      max_size       = 4
      instance_types = ["t3.small"]
    }
  }
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # VPC outputs directly to EKS module
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets

  eks_managed_node_groups = local.eks_managed_node_groups

  my_ip_address = var.my_ip_address
}
