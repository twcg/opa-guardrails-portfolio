package terraform.s3_baseline

import future.keywords.if
import future.keywords.in

# ----------------------------
# CIS-ish baseline checks (offline)
# ----------------------------

# 1) Public ACLs not allowed
deny contains msg if {
  some acl_name
  acl := input.resource.aws_s3_bucket_acl[acl_name][_]
  is_public_acl(acl.acl)

  msg := sprintf("CIS Baseline: S3 bucket ACL is public (%s). Public ACLs are not allowed.", [acl.acl])
}

# 2) Every bucket must have a public access block attached
deny contains msg if {
  some bucket_name
  bucket := input.resource.aws_s3_bucket[bucket_name][_]

  not has_public_access_block(bucket_name)

  msg := sprintf("CIS Baseline: S3 bucket aws_s3_bucket.%s is missing aws_s3_bucket_public_access_block.", [bucket_name])
}

# ----------------------------
# Helpers
# ----------------------------

is_public_acl(v) if {
  v in {"public-read", "public-read-write"}
}

has_public_access_block(bucket_name) if {
  some pab_name
  pab := input.resource.aws_s3_bucket_public_access_block[pab_name][_]

  # Must reference this bucket (offline-safe: matches TF interpolation strings)
  bucket_ref_matches(pab.bucket, bucket_name)

  # Strong block settings (typical "block all public access")
  pab.block_public_acls == true
  pab.ignore_public_acls == true
  pab.block_public_policy == true
  pab.restrict_public_buckets == true
}

bucket_ref_matches(ref, bucket_name) if {
  ref == sprintf("${aws_s3_bucket.%s.id}", [bucket_name])
}

bucket_ref_matches(ref, bucket_name) if {
  ref == sprintf("${aws_s3_bucket.%s.arn}", [bucket_name])
}

bucket_ref_matches(ref, bucket_name) if {
  ref == sprintf("${aws_s3_bucket.%s.bucket}", [bucket_name])
}