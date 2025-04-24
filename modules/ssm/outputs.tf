output "database_config_parameter_name" {
  description = "The name of the SSM parameter storing database configuration"
  value       = aws_ssm_parameter.database_config.name
}

output "database_config_parameter_arn" {
  description = "The ARN of the SSM parameter storing database configuration"
  value       = aws_ssm_parameter.database_config.arn
}

output "database_config_version" {
  description = "The version of the SSM parameter"
  value       = aws_ssm_parameter.database_config.version
}

# output "parameter_path" {
#   description = "Base path for SSM parameters"
#   value       = local.parameter_path
# }

# output "kms_key_arn" {
#   description = "The ARN of the KMS key used for parameter encryption"
#   value       = aws_kms_key.ssm_key.arn
# }

# output "kms_key_id" {
#   description = "The ID of the KMS key used for parameter encryption"
#   value       = aws_kms_key.ssm_key.key_id
# }
