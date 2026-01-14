package terraform.s3_baseline

# --------------------------------------------------
# 1) Public ACLs not allowed
# --------------------------------------------------
deny[msg] {
  some acl_name
  acl := input.resource.aws_s3_bucket_acl[acl_name][_]
  is_public_acl(acl.acl)

  msg := sprintf(
    "CIS Baseline: S3 bucket ACL is public (%s). Public ACLs are not allowed.",
    [acl.acl]
  )
}

# --------------------------------------------------
# 2) Every bucket must have a public access block
# --------------------------------------------------
deny[msg] {
  some bucket_name
  _ := input.resource.aws_s3_bucket[bucket_name][_]

  not has_public_access_block(bucket_name)

  msg := sprintf(
    "CIS Baseline: S3 bucket aws_s3_bucket.%s is missing aws_s3_bucket_public_access_block.",
    [bucket_name]
  )
}

# --------------------------------------------------
# Helpers (classic Rego, OPA 0.69 compatible)
# --------------------------------------------------

is_public_acl(v) {
  v == "public-read"
} else {
  v == "public-read-write"
}

has_public_access_block(bucket_name) {
  some pab_name
  pab := input.resource.aws_s3_bucket_public_access_block[pab_name][_]

  bucket_ref_matches(pab.bucket, bucket_name)

  pab.block_public_acls == true
  pab.ignore_public_acls == true
  pab.block_public_policy == true
  pab.restrict_public_buckets == true
}

# Accept both interpolation-style and reference-style bucket bindings
bucket_ref_matches(ref, bucket_name) {
  ref == sprintf("${aws_s3_bucket.%s.id}", [bucket_name])
} else {
  ref == sprintf("${aws_s3_bucket.%s.arn}", [bucket_name])
} else {
  ref == sprintf("${aws_s3_bucket.%s.bucket}", [bucket_name])
} else {
  ref == sprintf("aws_s3_bucket.%s.id", [bucket_name])
} else {
  ref == sprintf("aws_s3_bucket.%s.arn", [bucket_name])
} else {
  ref == sprintf("aws_s3_bucket.%s.bucket", [bucket_name])
}
