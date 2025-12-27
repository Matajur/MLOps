terraform {
  backend "s3" {
    bucket         = "terraform-mlops-state-014885976360" # put here your own account id
    key            = "argocd/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
