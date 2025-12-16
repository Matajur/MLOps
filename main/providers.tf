provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "mlops-course"
      ManagedBy = "terraform"
    }
  }
}
