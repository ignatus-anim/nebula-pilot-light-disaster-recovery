
output "primary_db_endpoint" {
  description = "The connection endpoint for the primary RDS instance"
  value       = var.environment_name == "primary" ? aws_db_instance.nebula_primary_db_instance[0].endpoint : null
}

output "primary_db_arn" {
  description = "The ARN of the primary RDS instance"
  value       = var.environment_name == "primary" ? aws_db_instance.nebula_primary_db_instance[0].arn : null
}


# output "db_security_group_id" {
#   description = "The ID of the database security group"
#   value       = aws_security_group.rds_sg.id
# }

output "db_instance_id" {
  description = "The instance ID of the RDS instance"
  value       = var.environment_name == "primary" ? aws_db_instance.nebula_primary_db_instance[0].id : null
}

# Output the security group ID
output "rds_security_group_id" {
  value = aws_security_group.rds_sg.id
}