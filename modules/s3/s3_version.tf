# ---------------------------------------------------------------------------------------------------------------------
# S3 BUCKET VERSIONING - PRIMARY AND DR REGIONS
# ---------------------------------------------------------------------------------------------------------------------

# Primary Bucket Versioning
# ------------------------
# Environment: Primary Region
# Purpose: Enable versioning for data protection
# Required for: Cross-region replication
# Created via: envs/primary/main.tf
resource "aws_s3_bucket_versioning" "nebula_primary_version" {
  provider = aws.primary
  bucket   = aws_s3_bucket.nebula_primary_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# DR Bucket Versioning
# -------------------
# Environment: DR Region
# Purpose: Enable versioning for replicated data
# Required for: Receiving replicated objects
# Created via: envs/dr/main.tf
resource "aws_s3_bucket_versioning" "nebula_dr_version" {
  provider = aws.dr
  bucket   = aws_s3_bucket.nebula_dr_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

