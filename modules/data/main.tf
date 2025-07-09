########################################################
# Random suffix and bucket names
resource "random_id" "suffix" { byte_length = 4 }

locals {
  primary_bucket_name   = "${var.bucket_name_prefix}-east-${random_id.suffix.hex}"
  secondary_bucket_name = "${var.bucket_name_prefix}-west-${random_id.suffix.hex}"
}
########################################################
# Buckets (east = default provider, west = aliased)
resource "aws_s3_bucket" "primary" {
  bucket = local.primary_bucket_name
  tags   = { Name = "east-dr" }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "secondary" {
  provider = aws.west
  bucket   = local.secondary_bucket_name
  tags     = { Name = "west-dr" }
  lifecycle {
    prevent_destroy = true
  }
}

########################################################
# Versioning
resource "aws_s3_bucket_versioning" "primary" {
  bucket = aws_s3_bucket.primary.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_versioning" "secondary" {
  provider = aws.west
  bucket   = aws_s3_bucket.secondary.id
  versioning_configuration { status = "Enabled" }
}

########################################################
# Replication role (trust policy) ──────────────────────
resource "aws_iam_role" "s3_replication_role" {
  name = "s3-replication-role-east-to-west-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "s3.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

########################################################
# Inline permissions for the role
resource "aws_iam_role_policy" "s3_replication_policy" {
  role = aws_iam_role.s3_replication_role.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetReplicationConfiguration", "s3:ListBucket"],
        Resource = [aws_s3_bucket.primary.arn]
      },
      {
        Effect   = "Allow",
        Action   = ["s3:GetObjectVersion", "s3:GetObjectVersionAcl"],
        Resource = ["${aws_s3_bucket.primary.arn}/*"]
      },
      {
        Effect   = "Allow",
        Action   = ["s3:ReplicateObject", "s3:ReplicateDelete", "s3:ReplicateTags"],
        Resource = ["${aws_s3_bucket.secondary.arn}/*"]
      }
    ]
  })
}

########################################################
# Bucket-policy for the **destination** bucket
data "aws_iam_policy_document" "dest_policy" {
  statement {
    sid    = "AllowReplicationFromPrimary"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.s3_replication_role.arn]
    }

    actions   = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags"
    ]

    resources = ["${aws_s3_bucket.secondary.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "secondary_policy" {
  provider = aws.west
  bucket   = aws_s3_bucket.secondary.id
  policy   = data.aws_iam_policy_document.dest_policy.json
}

########################################################
# Replication configuration on the **source** bucket
resource "aws_s3_bucket_replication_configuration" "replication" {
  bucket = aws_s3_bucket.primary.id
  role   = aws_iam_role.s3_replication_role.arn

  rule {
    id     = "crr-east-to-west"
    status = "Enabled"

    delete_marker_replication { status = "Disabled" }

    destination {
      bucket        = aws_s3_bucket.secondary.arn
      storage_class = "STANDARD"
    }

    filter { prefix = "" }   # replicate everything
  }

  depends_on = [
    aws_s3_bucket_versioning.primary,
    aws_s3_bucket_versioning.secondary,
    aws_s3_bucket_policy.secondary_policy
  ]
}
