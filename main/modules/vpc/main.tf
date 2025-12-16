module "this_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.name
  cidr = var.vpc_cidr

  azs = var.azs

  # one public and one private per AZ
  public_subnets  = [for i, az in var.azs : cidrsubnet(var.vpc_cidr, var.subnet_bits, i)]
  private_subnets = [for i, az in var.azs : cidrsubnet(var.vpc_cidr, var.subnet_bits, i + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"            = "1"
  }
}
