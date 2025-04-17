
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

