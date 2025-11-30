terraform {
  backend "s3" {
    bucket  = "mlops-tfstate-matajur"
    key     = "global/s3/terraform.tfstate"
    region  = "us-east-1"
    profile = "default"
  }
}
