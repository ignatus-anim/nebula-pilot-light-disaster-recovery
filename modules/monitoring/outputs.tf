output "sns_topic_arn" {
  description = "ARN of the SNS topic for monitoring alerts"
  value       = aws_sns_topic.monitoring_alerts.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic for monitoring alerts"
  value       = aws_sns_topic.monitoring_alerts.name
}

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "alarm_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  value       = aws_sns_topic.alarm_topic.arn
}

# output "metric_namespace" {
#   description = "Namespace used for custom metrics"
#   value       = local.metric_namespace
# }

output "log_group_names" {
  description = "Names of the CloudWatch log groups"
  value       = aws_cloudwatch_log_group.service_logs[*].name
}
