# ---------------------------------------------------------------------------------------------------------------------
# RDS CLOUDWATCH ALARMS
# ---------------------------------------------------------------------------------------------------------------------
# These alarms monitor RDS instances in both primary and DR regions:
# - CPU Utilization: Monitors database processor usage
# - Storage Space: Monitors available storage
# - Connection Count: Monitors number of database connections
# All metrics are built-in RDS metrics (no additional agent required)

# RDS CPU Utilization Alarm
# ------------------------
# Purpose: Monitor CPU usage of RDS instances
# Trigger: When CPU usage exceeds threshold for 2 consecutive 5-minute periods
# Action: Sends notification to SNS topic
# Note: Critical for identifying performance issues and capacity needs
resource "aws_cloudwatch_metric_alarm" "rds_cpu_utilization_high" {
  alarm_name          = "${var.project_name}-${var.environment_name}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"   # Built-in RDS metric
  namespace          = "AWS/RDS"          # AWS namespace for RDS metrics
  period             = "300"              # 5 minutes
  statistic          = "Average"
  threshold          = var.rds_cpu_threshold
  alarm_description  = "RDS CPU utilization has exceeded ${var.rds_cpu_threshold}%"
  alarm_actions      = [aws_sns_topic.monitoring_alerts.arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id  # Links alarm to specific RDS instance
  }
}

# RDS Free Storage Space Alarm
# ---------------------------
# Purpose: Monitor available storage space on RDS instances
# Trigger: When free storage falls below threshold for 2 consecutive 5-minute periods
# Action: Sends notification to SNS topic
# Note: Critical for preventing database outages due to storage issues
resource "aws_cloudwatch_metric_alarm" "rds_free_storage_space_low" {
  alarm_name          = "${var.project_name}-${var.environment_name}-rds-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeStorageSpace"  # Built-in RDS metric
  namespace          = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = var.rds_storage_threshold
  alarm_description  = "RDS free storage space is below ${var.rds_storage_threshold} bytes"
  alarm_actions      = [aws_sns_topic.monitoring_alerts.arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }
}

# RDS Connection Count Alarm
# ------------------------
# Purpose: Monitor number of database connections
# Trigger: When connection count exceeds threshold for 2 consecutive 5-minute periods
# Action: Sends notification to SNS topic
# Note: Important for identifying connection leaks or capacity issues
resource "aws_cloudwatch_metric_alarm" "rds_connection_count_high" {
  alarm_name          = "${var.project_name}-${var.environment_name}-rds-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"  # Built-in RDS metric
  namespace          = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = var.rds_connection_threshold
  alarm_description  = "RDS connection count has exceeded ${var.rds_connection_threshold}"
  alarm_actions      = [aws_sns_topic.monitoring_alerts.arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }
}
