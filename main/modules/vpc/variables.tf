variable "name" {
  type        = string
  description = "Name prefix for VPC and resources"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "azs" {
  type        = list(string)
  description = "List of AZs to create subnets in"
}

# how many extra bits to add (VPC mask + subnet_bits = subnet mask)
variable "subnet_bits" {
  type        = number
  description = "Number of bits to add to the VPC mask when carving subnets (e.g. 4 -> /20 if vpc is /16)"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name used for subnet tagging"
}
