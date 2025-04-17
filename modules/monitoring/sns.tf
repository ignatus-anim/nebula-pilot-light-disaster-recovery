resource "aws_sns_topic" "failover" {
  provider = aws.primary
  name     = "${var.project_name}-failover-topic"
}

resource "aws_sns_topic_subscription" "failover_lambda" {
  provider  = aws.primary
  topic_arn = aws_sns_topic.failover.arn
  protocol  = "lambda"
  endpoint  = var.failover_lambda_arn
}