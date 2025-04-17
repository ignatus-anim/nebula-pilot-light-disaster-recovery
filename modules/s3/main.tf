# ---------------------------------------------------------------------------------------------------------------------
# S3 BUCKETS - PRIMARY AND DR REGIONS
# ---------------------------------------------------------------------------------------------------------------------

# Random suffix generator
# ----------------------
# Used by both primary and DR buckets to ensure globally unique names
# Created once and shared between both buckets for naming consistency
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Primary S3 Bucket
# ----------------
# Environment: Primary Region (e.g., eu-west-1)
# Purpose: Main production storage bucket
# Usage: Direct application access and data storage
resource "aws_s3_bucket" "nebula_primary_bucket" {
  provider = aws.primary
  bucket   = "${var.project_name}-primary-${random_id.bucket_suffix.hex}"

}

# DR S3 Bucket
# -----------
# Environment: DR Region (e.g., us-east-1)
# Purpose: Disaster recovery backup storage
# Usage: Replication target for primary bucket
resource "aws_s3_bucket" "nebula_dr_bucket" {
  provider = aws.dr
  bucket   = "${var.project_name}-dr-${random_id.bucket_suffix.hex}"
  # Only add DR = true tag since other tags are in provider's default_tags

}

