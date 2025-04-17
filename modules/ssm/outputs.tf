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