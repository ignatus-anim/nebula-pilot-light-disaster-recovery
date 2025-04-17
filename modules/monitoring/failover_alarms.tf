resource "aws_cloudwatch_metric_alarm" "failover_trigger" {
  provider            = aws.primary
  alarm_name          = "${var.project_name}-failover-trigger"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period             = "60"
  statistic          = "Minimum"
  threshold          = "0"
  alarm_description  = "Trigger failover when primary health check fails"
  alarm_actions      = [aws_sns_topic.failover.arn]

  dimensions = {
    HealthCheckId = var.health_check_id
  }
}

