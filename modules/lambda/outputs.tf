
output "primary_function_name" {
  description = "The name of the primary Lambda function"
  value       = aws_lambda_function.nebula_primary.function_name
}

output "primary_function_arn" {
  description = "The ARN of the primary Lambda function"
  value       = aws_lambda_function.nebula_primary.arn
}

output "dr_function_name" {
  description = "The name of the DR Lambda function"
  value       = aws_lambda_function.dr.function_name
}

output "dr_function_arn" {
  description = "The ARN of the DR Lambda function"
  value       = aws_lambda_function.dr.arn
}

output "lambda_role_arn" {
  description = "The ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_exec.arn
}

output "health_check_id" {
  description = "The ID of the Route53 health check used for failover monitoring"
  value       = aws_lambda_function.failover_orchestrator.id
}

output "failover_lambda_arn" {
  description = "The ARN of the failover orchestrator Lambda function"
  value       = aws_lambda_function.failover_orchestrator.arn
}

output "lambda_security_group_id" {
  description = "The ID of the Lambda security group"
  value       = aws_security_group.lambda_sg.id
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for Lambda functions"
  value       = aws_cloudwatch_log_group.lambda_log_group.name
}

