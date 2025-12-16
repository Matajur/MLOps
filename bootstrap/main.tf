data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "tf_state" {
  bucket = "terraform-mlops-state-${data.aws_caller_identity.current.account_id}"
}

resource "aws_dynamodb_table" "tf_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
