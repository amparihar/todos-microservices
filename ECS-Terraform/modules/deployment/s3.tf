resource "aws_s3_bucket" "artifacts" {
  bucket = "deployment-artifacts-${local.name_suffix}-${random_string.random.result}"
  acl    = "private"
  force_destroy = true
  lifecycle_rule {
    id      = "clean-up"
    enabled = "true"
    expiration {
      days = 7
    }
  }
}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}
