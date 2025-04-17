# ---------------------------------------------------------------------------------------------------------------------
# S3 CROSS-REGION REPLICATION (CRR) - PRIMARY TO DR
# ---------------------------------------------------------------------------------------------------------------------

# Cross-Region Replication Configuration
# ------------------------------------
# Environment: Primary Region
# Purpose: Replicate objects to DR bucket
# Dependencies: 
#   - Primary bucket versioning must be enabled
#   - IAM replication role must exist
# Created via: envs/primary/main.tf
resource "aws_s3_bucket_replication_configuration" "nebula_crr" {
  provider = aws.primary
  depends_on = [aws_s3_bucket_versioning.nebula_primary_version]
  
  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.nebula_primary_bucket.id

  rule {
    id     = "full-bucket-replication"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.nebula_dr_bucket.arn
      storage_class = "STANDARD"  # Objects replicated using STANDARD storage class
    }
  }
}
