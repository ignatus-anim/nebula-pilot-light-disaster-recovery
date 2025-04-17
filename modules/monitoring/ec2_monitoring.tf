# ---------------------------------------------------------------------------------------------------------------------
# EC2 CLOUDWATCH ALARMS
# ---------------------------------------------------------------------------------------------------------------------
# These alarms monitor EC2 instances in both primary and DR regions for various metrics:
# - CPU Utilization: Monitors processor usage
# - Memory Usage: Requires CloudWatch agent on EC2
# - Disk Usage: Requires CloudWatch agent on EC2
# All alarms trigger notifications through SNS when thresholds are exceeded

# CPU Utilization Alarm
# --------------------
# Purpose: Monitor CPU usage of EC2 instances
# Trigger: When CPU usage exceeds threshold for 2 consecutive 5-minute periods
# Action: Sends notification to SNS topic
# Note: Uses built-in AWS/EC2 metrics (no agent required)
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  alarm_name          = "${var.project_name}-${var.environment_name}-cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"                # Number of periods to evaluate
  metric_name         = "CPUUtilization"   # AWS default metric
  namespace          = "AWS/EC2"          # AWS namespace for EC2 metrics
  period             = "300"              # 300 seconds = 5 minutes
  statistic          = "Average"          # Type of statistic to apply
  threshold          = var.cpu_utilization_threshold
  alarm_description  = "CPU utilization has exceeded ${var.cpu_utilization_threshold}%"
  alarm_actions      = [aws_sns_topic.monitoring_alerts.arn]

  dimensions = {
    InstanceId = var.ec2_instance_id      # Links alarm to specific EC2 instance
  }
}

# Memory Utilization Alarm
# -----------------------
# Purpose: Monitor memory usage of EC2 instances
# Trigger: When memory usage exceeds threshold for 2 consecutive 5-minute periods
# Action: Sends notification to SNS topic
# Requirements: 
# - CloudWatch agent must be installed on EC2
# - Agent must be configured to collect memory metrics
# - IAM role must allow CloudWatch agent actions
resource "aws_cloudwatch_metric_alarm" "memory_utilization_high" {
  alarm_name          = "${var.project_name}-${var.environment_name}-memory-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "mem_used_percent" # Custom metric from CloudWatch agent
  namespace          = "CWAgent"          # CloudWatch agent namespace
  period             = "300"
  statistic          = "Average"
  threshold          = var.memory_utilization_threshold
  alarm_description  = "Memory utilization has exceeded ${var.memory_utilization_threshold}%"
  alarm_actions      = [aws_sns_topic.monitoring_alerts.arn]

  dimensions = {
    InstanceId = var.ec2_instance_id
  }
}

# Disk Usage Alarm
# ---------------
# Purpose: Monitor disk space usage of EC2 instances
# Trigger: When disk usage exceeds threshold for 2 consecutive 5-minute periods
# Action: Sends notification to SNS topic
# Requirements:
# - CloudWatch agent must be installed on EC2
# - Agent must be configured to collect disk metrics
# - IAM role must allow CloudWatch agent actions
resource "aws_cloudwatch_metric_alarm" "disk_usage_high" {
  alarm_name          = "${var.project_name}-${var.environment_name}-disk-usage-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "disk_used_percent" # Custom metric from CloudWatch agent
  namespace          = "CWAgent"           # CloudWatch agent namespace
  period             = "300"
  statistic          = "Average"
  threshold          = var.disk_usage_threshold
  alarm_description  = "Disk usage has exceeded ${var.disk_usage_threshold}%"
  alarm_actions      = [aws_sns_topic.monitoring_alerts.arn]

  dimensions = {
    InstanceId = var.ec2_instance_id
    path      = "/"                       # Root volume path
    fstype    = "ext4"                    # Filesystem type
  }
}
