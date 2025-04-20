# # Network Health Alarms
# resource "aws_cloudwatch_metric_alarm" "network_packet_loss" {
#   alarm_name          = "${var.project_name}-${var.environment_name}-network-packet-loss"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = "3"
#   metric_name         = "PacketLossCount"
#   namespace          = "AWS/NetworkELB"
#   period             = "300"
#   statistic          = "Average"
#   threshold          = var.packet_loss_threshold
#   alarm_description  = "Network packet loss has exceeded threshold"
#   alarm_actions      = [aws_sns_topic.monitoring_alerts.arn]

#   dimensions = {
#     LoadBalancer = var.nlb_name
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "vpc_status" {
#   alarm_name          = "${var.project_name}-${var.environment_name}-vpc-status"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "VPCStatus"
#   namespace          = "AWS/VPC"
#   period             = "300"
#   statistic          = "Maximum"
#   threshold          = 0
#   alarm_description  = "VPC connectivity issues detected"
#   alarm_actions      = [aws_sns_topic.monitoring_alerts.arn]

#   dimensions = {
#     VpcId = var.vpc_id
#   }
# }