terraform {
  backend "s3" {
    bucket         = "terraform-mlops-state-158583182440" # put here your own account id
    key            = "argocd/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
