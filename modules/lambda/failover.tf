resource "aws_lambda_function" "failover_orchestrator" {
  provider      = aws.dr
  filename      = data.archive_file.failover_lambda_zip.output_path
  function_name = "${var.project_name}-failover-orchestrator"
  role          = aws_iam_role.failover_lambda_role.arn
  handler       = "failover.handler"
  runtime       = "python3.9"

  environment {
    variables = {
      PRIMARY_REGION = var.primary_region
      DR_REGION     = var.dr_region
      RDS_INSTANCE  = var.rds_instance_id
      ASG_NAME      = var.asg_name
    }
  }
}

data "archive_file" "failover_lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/failover_lambda.zip"
  source {
    content  = <<EOF
import boto3
import os

def lambda_handler(event, context):
    asg_client = boto3.client('autoscaling')
    rds_client = boto3.client('rds')
    
    try:
        # Promote RDS read replica to master
        rds_client.promote_read_replica(
            DBInstanceIdentifier=event['rds_instance']
        )
        
        # Scale up DR ASG
        asg_client.update_auto_scaling_group(
            AutoScalingGroupName=event['asg_name'],
            MinSize=1,
            MaxSize=3,
            DesiredCapacity=1  # Start with 1 instance
        )
        
        return {
            'statusCode': 200,
            'body': 'DR failover initiated successfully'
        }
    except Exception as e:
        print(f"Error during failover: {str(e)}")
        raise
EOF
    filename = "failover.py"
  }
}

resource "aws_iam_role" "failover_lambda_role" {
  provider = aws.dr
  name     = "${var.project_name}-failover-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "failover_lambda_policy" {
  provider = aws.dr
  name     = "${var.project_name}-failover-lambda-policy"
  role     = aws_iam_role.failover_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:PromoteReadReplica",
          "autoscaling:UpdateAutoScalingGroup"
        ]
        Resource = ["*"]
      }
    ]
  })
}
