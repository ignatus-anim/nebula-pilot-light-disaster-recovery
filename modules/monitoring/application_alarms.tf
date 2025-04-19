# Application Health Alarms
resource "aws_cloudwatch_metric_alarm" "application_latency_high" {
  alarm_name          = "${var.project_name}-${var.environment_name}-app-latency-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "ApplicationLatency"
  namespace          = "AWS/ApplicationELB"
  period             = "300"
  statistic          = "Average"
  threshold          = var.application_latency_threshold
  alarm_description  = "Application latency has exceeded threshold"
  alarm_actions      = [aws_sns_topic.monitoring_alerts.arn]

  dimensions = {
    LoadBalancer = var.alb_name
  }
}

resource "aws_cloudwatch_metric_alarm" "application_5xx_errors" {
  alarm_name          = "${var.project_name}-${var.environment_name}-app-5xx-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace          = "AWS/ApplicationELB"
  period             = "300"
  statistic          = "Sum"
  threshold          = var.error_threshold
  alarm_description  = "Application 5XX errors have exceeded threshold"
  alarm_actions      = [aws_sns_topic.monitoring_alerts.arn]

  dimensions = {
    LoadBalancer = var.alb_name
  }
}