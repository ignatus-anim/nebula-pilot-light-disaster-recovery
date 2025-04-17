resource "aws_ssm_parameter" "database_config" {
  name        = "/${var.project_name}/${var.environment_name}/database"
  description = "Database configuration"
  type        = "SecureString"
  value       = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = var.db_endpoint
  })

  # Remove duplicate tags as they're already set in provider's default_tags
  # tags = {
  #   Environment = var.environment_name
  #   Project     = var.project_name
  # }
}
