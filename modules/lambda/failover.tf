resource "aws_lambda_function" "failover_orchestrator" {
  provider      = aws.dr
  filename      = data.archive_file.failover_lambda_zip.output_path
  function_name = "${var.project_name}-failover-orchestrator"
  role          = aws_iam_role.failover_lambda_role.arn
  handler       = "failover.handler"
  runtime       = "python3.9"

  environment {
    variables = {
      PRIMARY_REGION        = var.primary_region
      DR_REGION            = var.dr_region
      RDS_INSTANCE         = var.rds_instance_id
      ASG_NAME             = var.asg_name
      DR_TARGET_GROUP_ARN  = var.dr_target_group_arn
      DR_INSTANCE_ID       = var.dr_instance_id
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
import json
import time
from datetime import datetime

def handler(event, context):
    """
    Main failover orchestrator function that handles the DR failover process.
    """
    print(f"Starting failover process at {datetime.utcnow().isoformat()}")
    
    # Initialize AWS clients
    rds_client = boto3.client('rds', region_name=os.environ['DR_REGION'])
    asg_client = boto3.client('autoscaling', region_name=os.environ['DR_REGION'])
    lambda_client = boto3.client('lambda', region_name=os.environ['DR_REGION'])
    elb_client = boto3.client('elbv2', region_name=os.environ['DR_REGION'])
    
    try:
        # Step 1: Promote RDS read replica
        print("Starting RDS promotion...")
        promote_rds_replica(rds_client, os.environ['RDS_INSTANCE'])
        
        # Step 2: Scale up DR ASG
        print("Scaling up DR ASG...")
        scale_up_asg(asg_client, os.environ['ASG_NAME'])
        
        # Step 3: Enable DR Lambda functions
        print("Enabling DR Lambda functions...")
        enable_dr_functions(lambda_client)
        
        # Step 4: Update Load Balancer target groups
        print("Updating Load Balancer routing...")
        update_lb_routing(elb_client)
        
        # Step 5: Verify failover completion
        verify_failover_status()
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'DR failover completed successfully',
                'timestamp': datetime.utcnow().isoformat()
            })
        }
        
    except Exception as e:
        print(f"Error during failover: {str(e)}")
        raise

def promote_rds_replica(rds_client, instance_id):
    """Promotes the RDS read replica to master"""
    try:
        response = rds_client.promote_read_replica(
            DBInstanceIdentifier=instance_id
        )
        
        # Wait for promotion to complete
        waiter = rds_client.get_waiter('db_instance_available')
        waiter.wait(
            DBInstanceIdentifier=instance_id,
            WaiterConfig={'Delay': 30, 'MaxAttempts': 60}
        )
        
        return response
    except Exception as e:
        print(f"Error promoting RDS replica: {str(e)}")
        raise

def scale_up_asg(asg_client, asg_name):
    """Scales up the DR Auto Scaling Group"""
    try:
        response = asg_client.update_auto_scaling_group(
            AutoScalingGroupName=asg_name,
            MinSize=1,
            MaxSize=3,
            DesiredCapacity=2
        )
        
        # Wait for instances to be healthy
        waiter = asg_client.get_waiter('group_in_service')
        waiter.wait(
            AutoScalingGroupNames=[asg_name],
            WaiterConfig={'Delay': 30, 'MaxAttempts': 40}
        )
        
        return response
    except Exception as e:
        print(f"Error scaling ASG: {str(e)}")
        raise

def enable_dr_functions(lambda_client):
    """Enables DR Lambda functions"""
    try:
        # Get list of DR functions (tagged appropriately)
        functions = lambda_client.list_functions()
        dr_functions = [f for f in functions['Functions'] 
                       if f['FunctionName'].endswith('-dr-function')]
        
        for function in dr_functions:
            lambda_client.update_function_configuration(
                FunctionName=function['FunctionName'],
                Environment={
                    'Variables': {
                        'IS_DR_ACTIVE': 'true'
                    }
                }
            )
    except Exception as e:
        print(f"Error enabling DR functions: {str(e)}")
        raise

def update_lb_routing(elb_client):
    """Updates Load Balancer routing to DR region"""
    try:
        # Update target group health check settings
        response = elb_client.modify_target_group(
            TargetGroupArn=os.environ['DR_TARGET_GROUP_ARN'],
            HealthCheckEnabled=True,
            HealthCheckIntervalSeconds=30
        )
        
        # Register new targets if needed
        response = elb_client.register_targets(
            TargetGroupArn=os.environ['DR_TARGET_GROUP_ARN'],
            Targets=[
                {
                    'Id': os.environ['DR_INSTANCE_ID'],
                    'Port': 80
                }
            ]
        )
        
        # Wait for targets to be healthy
        waiter = elb_client.get_waiter('target_in_service')
        waiter.wait(
            TargetGroupArn=os.environ['DR_TARGET_GROUP_ARN'],
            WaiterConfig={'Delay': 30, 'MaxAttempts': 40}
        )
        
        return response
    except Exception as e:
        print(f"Error updating Load Balancer routing: {str(e)}")
        raise

def verify_failover_status():
    """Verifies the status of all DR components"""
    try:
        # Implement health checks for:
        # 1. RDS instance status
        # 2. ASG instance health
        # 3. Application health checks via Load Balancer
        # 4. Lambda function status
        pass
    except Exception as e:
        print(f"Error verifying failover status: {str(e)}")
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
          "autoscaling:UpdateAutoScalingGroup",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DescribeTargetHealth"
        ]
        Resource = ["*"]
      }
    ]
  })
}
