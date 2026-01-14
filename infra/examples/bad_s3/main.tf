provider "aws" {
  region                     = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

resource "aws_s3_bucket" "bad" {
  bucket = "example-bad-public-bucket"
}

resource "aws_s3_bucket_acl" "bad_acl" {
  bucket = aws_s3_bucket.bad.id
  acl    = "public-read"
}
