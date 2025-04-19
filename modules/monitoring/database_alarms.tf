# Additional Database Health Alarms
resource "aws_cloudwatch_metric_alarm" "rds_replica_lag" {
  alarm_name          = "${var.project_name}-${var.environment_name}-rds-replica-lag"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "ReplicaLag"
  namespace          = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = var.replica_lag_threshold
  alarm_description  = "RDS replica lag has exceeded threshold"
  alarm_actions      = [aws_sns_topic.monitoring_alerts.arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_deadlocks" {
  alarm_name          = "${var.project_name}-${var.environment_name}-rds-deadlocks"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Deadlocks"
  namespace          = "AWS/RDS"
  period             = "300"
  statistic          = "Sum"
  threshold          = var.deadlock_threshold
  alarm_description  = "Database deadlocks have exceeded threshold"
  alarm_actions      = [aws_sns_topic.monitoring_alerts.arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }
}