
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

