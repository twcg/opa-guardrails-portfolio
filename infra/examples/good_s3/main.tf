provider "aws" {
  region                     = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

resource "aws_s3_bucket" "good" {
  bucket = "example-good-private-bucket"
}

resource "aws_s3_bucket_public_access_block" "good_block" {
  bucket                  = aws_s3_bucket.good.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
