variable "region" {
  description = "Default AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "my-vpc"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}

variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
  default     = "1.31"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 2
}

variable "public_subnet_suffix_bits" {
  description = "How many additional bits to create subnets (added to VPC / mask)"
  type        = number
  default     = 4
}

variable "my_ip_address" {
  description = "Your public IP address for EKS cluster access"
  type        = string
  default     = "Put your IP here without /32"
}
