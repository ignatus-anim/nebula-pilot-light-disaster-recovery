# Systems Manager Automation document for daily AMI creation
resource "aws_ssm_document" "create_ami" {
  name            = "${var.project_name}-${var.environment_name}-daily-ami-backup"
  document_type   = "Automation"
  document_format = "YAML"

  content = <<DOC
schemaVersion: '0.3'
description: 'Create AMI from EC2 instance and copy to DR region'
parameters:
  InstanceId:
    type: String
    description: ID of the EC2 instance
  AMIName:
    type: String
    description: Name prefix for the AMI
  SourceRegion:
    type: String
    description: Source region
  DestinationRegion:
    type: String
    description: Destination region for AMI copy
mainSteps:
  - name: createImage
    action: 'aws:createImage'
    inputs:
      InstanceId: '{{ InstanceId }}'
      ImageName: '{{ AMIName }}-{{global:DATE_TIME}}'
      NoReboot: true
      TagSpecifications:
        - ResourceType: image
          Tags:
            - Key: Name
              Value: '{{ AMIName }}'
            - Key: Environment
              Value: ${var.environment_name}
            - Key: Project
              Value: ${var.project_name}
    outputs:
      - Name: ImageId
        Selector: '$.ImageId'
        Type: String
  - name: copyImage
    action: 'aws:copyImage'
    inputs:
      SourceImageId: '{{ createImage.ImageId }}'
      SourceRegion: '{{ SourceRegion }}'
      DestinationRegion: '{{ DestinationRegion }}'
      ImageName: '{{ AMIName }}-dr-{{global:DATE_TIME}}'
      Encrypted: true
DOC
}

# EventBridge rule to trigger the automation daily
resource "aws_cloudwatch_event_rule" "daily_ami" {
  count               = var.enable_ec2 ? 1 : 0
  name                = "${var.project_name}-${var.environment_name}-daily-ami"
  description         = "Trigger daily AMI creation"
  schedule_expression = "cron(0 1 * * ? *)" # Run at 1 AM UTC daily

  tags = merge(var.tags, {
    Name = "${var.project_name}-daily-ami-rule"
  })
}

# EventBridge target to execute SSM Automation
resource "aws_cloudwatch_event_target" "ssm_automation" {
  count     = var.enable_ec2 ? 1 : 0
  rule      = aws_cloudwatch_event_rule.daily_ami[0].name
  target_id = "SSMAutomation"
  arn       = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:automation-definition/${aws_ssm_document.create_ami.name}"
  role_arn  = aws_iam_role.eventbridge_role[0].arn

  input = jsonencode({
    InstanceId = aws_instance.nebula_primary_instance[0].id
    AMIName    = "${var.project_name}-primary-ami"
    SourceRegion = var.region
    DestinationRegion = var.dr_region
  })
}

# IAM role for EventBridge to execute SSM Automation
resource "aws_iam_role" "eventbridge_role" {
  count = var.enable_ec2 ? 1 : 0
  name  = "${var.project_name}-${var.environment_name}-eventbridge-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for EventBridge to execute SSM Automation
resource "aws_iam_role_policy" "eventbridge_policy" {
  count = var.enable_ec2 ? 1 : 0
  name  = "${var.project_name}-${var.environment_name}-eventbridge-policy"
  role  = aws_iam_role.eventbridge_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:StartAutomationExecution"
        ]
        Resource = [
          "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:automation-definition/${aws_ssm_document.create_ami.name}:*"
        ]
      }
    ]
  })
}