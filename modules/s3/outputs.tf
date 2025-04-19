
output "primary_bucket_id" {
  description = "The name of the primary S3 bucket"
  value       = aws_s3_bucket.nebula_primary_bucket.id
}

output "primary_bucket_arn" {
  description = "The ARN of the primary S3 bucket"
  value       = aws_s3_bucket.nebula_primary_bucket.arn
}

output "dr_bucket_id" {
  description = "The name of the DR S3 bucket"
  value       = aws_s3_bucket.nebula_dr_bucket.id
}

output "dr_bucket_arn" {
  description = "The ARN of the DR S3 bucket"
  value       = aws_s3_bucket.nebula_dr_bucket.arn
}

output "primary_bucket_domain_name" {
  description = "The domain name of the primary bucket"
  value       = aws_s3_bucket.nebula_primary_bucket.bucket_domain_name
}

output "dr_bucket_domain_name" {
  description = "The domain name of the DR bucket"
  value       = aws_s3_bucket.nebula_dr_bucket.bucket_domain_name
}

output "replication_role_arn" {
  description = "The ARN of the IAM role used for bucket replication"
  value       = aws_iam_role.replication_role.arn
}

