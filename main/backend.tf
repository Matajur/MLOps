# Backend does not support variables, so hardcoding values here

terraform {
  backend "s3" {
    bucket         = "terraform-mlops-state-158583182440" # put here you own account id
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
