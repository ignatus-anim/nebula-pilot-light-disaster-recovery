
output "primary_db_endpoint" {
  description = "The connection endpoint for the primary RDS instance"
  value       = var.environment_name == "primary" ? aws_db_instance.nebula_primary_db_instance[0].endpoint : null
}

output "primary_db_arn" {
  description = "The ARN of the primary RDS instance"
  value       = var.environment_name == "primary" ? aws_db_instance.nebula_primary_db_instance[0].arn : null
}

output "db_instance_id" {
  description = "The instance ID of the RDS instance"
  value       = var.environment_name == "primary" ? aws_db_instance.nebula_primary_db_instance[0].id : null
}

output "rds_security_group_id" {
  description = "The ID of the RDS security group"
  value       = aws_security_group.rds_sg.id
}

output "db_subnet_group_name" {
  description = "The name of the database subnet group"
  value       = aws_db_subnet_group.nebula_db_subnet_group.name
}

output "db_subnet_group_arn" {
  description = "The ARN of the database subnet group"
  value       = aws_db_subnet_group.nebula_db_subnet_group.arn
}

output "db_parameter_group_name" {
  description = "The name of the database parameter group"
  value       = aws_db_parameter_group.nebula_db_parameter_group.name
}

output "replica_db_endpoint" {
  description = "The connection endpoint for the replica RDS instance"
  value       = var.environment_name == "dr" ? aws_db_instance.nebula_dr_db_instance[0].endpoint : null
}

output "replica_db_arn" {
  description = "The ARN of the replica RDS instance"
  value       = var.environment_name == "dr" ? aws_db_instance.nebula_dr_db_instance[0].arn : null
}
