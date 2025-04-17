# ---------------------------------------------------------------------------------------------------------------------
# SNS TOPIC FOR MONITORING ALERTS
# ---------------------------------------------------------------------------------------------------------------------
# Purpose: Creates and configures SNS topic for sending monitoring alerts
# Usage: All CloudWatch alarms send notifications to this topic
# Note: Additional subscribers (email, Lambda, etc.) can be added to receive notifications

# SNS Topic
# ---------
# Creates the main SNS topic for all monitoring alerts
# This topic can have multiple subscribers (email, Lambda, etc.)
resource "aws_sns_topic" "monitoring_alerts" {
  name = "${var.project_name}-${var.environment_name}-monitoring-alerts"
}

# SNS Topic Policy
# ---------------
# Purpose: Defines who can publish to the SNS topic
# Allows: CloudWatch to publish alarm notifications
# Note: Additional publishers can be added as needed
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.monitoring_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Default SNS policy"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.monitoring_alerts.arn
      }
    ]
  })
}
