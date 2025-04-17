# ---------------------------------------------------------------------------------------------------------------------
# S3 LIFECYCLE RULES - PRIMARY AND DR REGIONS
# ---------------------------------------------------------------------------------------------------------------------

# Primary Bucket Lifecycle Rules
# ----------------------------
# Environment: Primary Region
# Purpose: Manage object storage classes and expiration
# Transitions:
#   1. STANDARD → STANDARD_IA (after ia_days)
#   2. STANDARD_IA → GLACIER (after glacier_days)
#   3. Delete objects (after expiration_days)
# Created via: envs/primary/main.tf
resource "aws_s3_bucket_lifecycle_configuration" "nebula_bucket_lifecycle" {
  bucket = aws_s3_bucket.nebula_primary_bucket.id

  rule {
    id     = "archive_old_objects"
    status = "Enabled"

    transition {
      days          = var.ia_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.glacier_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.expiration_days
    }
  }
}

# DR Bucket Lifecycle Rules
# -----------------------
# Environment: DR Region
# Purpose: Mirror primary bucket lifecycle rules
# Transitions: Same as primary bucket
# Note: Applied to replicated objects
# Created via: envs/dr/main.tf
resource "aws_s3_bucket_lifecycle_configuration" "nebula_dr_bucket_lifecycle" {
  bucket = aws_s3_bucket.nebula_dr_bucket.id

  rule {
    id     = "archive_old_objects"
    status = "Enabled"

    transition {
      days          = var.ia_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.glacier_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.expiration_days
    }
  }
}

