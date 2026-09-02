###############################################################################
# soc2-workshop-data-bucket
#
# Object ownership is BucketOwnerPreferred, so ACLs are still active and the
# bucket carries a public-read canned ACL. No bucket policy, no versioning
# configuration, no access logging, no lifecycle rules are present on the live
# bucket, so no corresponding resources are declared here.
###############################################################################

resource "aws_s3_bucket" "data" {
  bucket = "${var.name_prefix}-data-bucket-${data.aws_caller_identity.current.account_id}-${random_string.bucket_suffix.result}"
}

resource "aws_s3_bucket_public_access_block" "data_fix" {
  bucket                  = aws_s3_bucket.data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_ownership_controls" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket = aws_s3_bucket.data.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "data" {
  bucket = aws_s3_bucket.data.id
  acl    = "public-read"

  # The canned public-read ACL is only accepted once ACLs are enabled by the
  # ownership controls and the public access block stops overriding it.
  depends_on = [
    aws_s3_bucket_ownership_controls.data,
    aws_s3_bucket_public_access_block.data,
  ]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

###############################################################################
# soc2-workshop-trail-logs
#
# Destination bucket for the CloudTrail trail. Object ownership is
# BucketOwnerEnforced, which disables ACLs entirely, so no aws_s3_bucket_acl
# resource applies here. No versioning, logging, or lifecycle configuration is
# present on the live bucket.
###############################################################################

resource "aws_s3_bucket" "trail_logs" {
  bucket = "${var.name_prefix}-trail-logs-${data.aws_caller_identity.current.account_id}-${random_string.bucket_suffix.result}"
}

resource "aws_s3_bucket_ownership_controls" "trail_logs" {
  bucket = aws_s3_bucket.trail_logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "trail_logs" {
  bucket = aws_s3_bucket.trail_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "trail_logs" {
  bucket = aws_s3_bucket.trail_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_policy" "trail_logs" {
  bucket = aws_s3_bucket.trail_logs.id
  policy = data.aws_iam_policy_document.trail_logs.json
}

data "aws_iam_policy_document" "trail_logs" {
  statement {
    sid       = "AWSCloudTrailAclCheck"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.trail_logs.arn]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  statement {
    sid       = "AWSCloudTrailWrite"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.trail_logs.arn}/AWSLogs/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}
