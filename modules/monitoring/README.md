# Nebula DR Solution - Monitoring Module

## Overview
This module implements comprehensive monitoring for the Nebula DR solution using CloudWatch alarms, SNS notifications, and automated failover triggers.

## Features
- EC2 instance monitoring (CPU, memory, disk)
- RDS monitoring (CPU, storage, connections)
- Automated failover triggers via Route53 health checks
- SNS notification system
- Cross-region monitoring support

## Usage

```hcl
module "monitoring" {
  source = "../../modules/monitoring"

  project_name         = "my-project"
  environment_name     = "production"
  health_check_id      = "abc123"
  failover_lambda_arn  = "arn:aws:lambda:region:account:function:failover"
  
  # Optional: Override default thresholds
  cpu_utilization_threshold    = 80
  memory_utilization_threshold = 80
  disk_usage_threshold        = 85
  rds_cpu_threshold          = 80
  rds_storage_threshold      = 10000000000  # 10GB in bytes
  rds_connection_threshold   = 100
}
```

## Resources Created

### CloudWatch Alarms

#### EC2 Alarms
- CPU Utilization (`aws_cloudwatch_metric_alarm.cpu_utilization_high`)
- Memory Usage (`aws_cloudwatch_metric_alarm.memory_utilization_high`)
- Disk Usage (`aws_cloudwatch_metric_alarm.disk_usage_high`)

#### RDS Alarms
- CPU Utilization (`aws_cloudwatch_metric_alarm.rds_cpu_utilization_high`)
- Storage Space (`aws_cloudwatch_metric_alarm.rds_free_storage_space_low`)
- Connection Count (`aws_cloudwatch_metric_alarm.rds_connection_count_high`)

#### Failover Alarms
- Health Check (`aws_cloudwatch_metric_alarm.failover_trigger`)

### SNS Topics
- Monitoring Alerts (`aws_sns_topic.monitoring_alerts`)
- Failover Notifications (`aws_sns_topic.failover`)

## Requirements

### EC2 Instance Requirements
1. CloudWatch agent installation for memory and disk metrics
2. IAM role with CloudWatch permissions
3. Agent configuration for custom metrics

### RDS Requirements
1. Enhanced monitoring enabled
2. Appropriate IAM roles

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Project identifier | `string` | n/a | yes |
| environment_name | Environment name | `string` | n/a | yes |
| health_check_id | Route53 health check ID | `string` | n/a | yes |
| failover_lambda_arn | Failover Lambda function ARN | `string` | n/a | yes |
| cpu_utilization_threshold | EC2 CPU threshold percentage | `number` | `80` | no |
| memory_utilization_threshold | EC2 memory threshold percentage | `number` | `80` | no |
| disk_usage_threshold | EC2 disk usage threshold percentage | `number` | `85` | no |
| rds_cpu_threshold | RDS CPU threshold percentage | `number` | `80` | no |
| rds_storage_threshold | RDS free storage threshold in bytes | `number` | `10000000000` | no |
| rds_connection_threshold | RDS connection count threshold | `number` | `100` | no |

## Outputs

| Name | Description |
|------|-------------|
| sns_topic_arn | ARN of the monitoring alerts SNS topic |
| sns_topic_name | Name of the monitoring alerts SNS topic |

## Alarm Configuration

### EC2 Monitoring

#### CPU Utilization
- **Metric**: CPUUtilization (AWS/EC2)
- **Period**: 5 minutes
- **Evaluation**: 2 consecutive periods
- **Action**: SNS notification

#### Memory Usage
- **Metric**: mem_used_percent (CWAgent)
- **Period**: 5 minutes
- **Evaluation**: 2 consecutive periods
- **Action**: SNS notification

#### Disk Usage
- **Metric**: disk_used_percent (CWAgent)
- **Period**: 5 minutes
- **Action**: SNS notification

### RDS Monitoring

#### CPU Utilization
- **Metric**: CPUUtilization (AWS/RDS)
- **Period**: 5 minutes
- **Evaluation**: 2 consecutive periods
- **Action**: SNS notification

#### Storage Space
- **Metric**: FreeStorageSpace (AWS/RDS)
- **Period**: 5 minutes
- **Evaluation**: 2 consecutive periods
- **Action**: SNS notification

#### Connection Count
- **Metric**: DatabaseConnections (AWS/RDS)
- **Period**: 5 minutes
- **Evaluation**: 2 consecutive periods
- **Action**: SNS notification

### Failover Monitoring
- **Type**: Route53 health check
- **Frequency**: 60 seconds
- **Trigger**: 3 consecutive failures
- **Action**: SNS notification to failover topic

## Best Practices

1. **Threshold Configuration**
   - Set appropriate thresholds based on workload
   - Configure sufficient evaluation periods
   - Avoid alert fatigue
   - Use meaningful alarm descriptions

2. **Monitoring Management**
   - Regularly review thresholds
   - Validate notification delivery
   - Test failover triggers
   - Keep documentation updated

3. **Cost Optimization**
   - Monitor API usage
   - Review metric retention
   - Optimize custom metrics
   - Use appropriate metric resolution

## Troubleshooting

### Common Issues

1. **Missing CloudWatch Agent Metrics**
   - Verify agent installation
   - Check IAM permissions
   - Validate agent configuration

2. **Delayed Notifications**
   - Check SNS delivery status
   - Verify subscription confirmation
   - Review CloudWatch logs

3. **False Positives**
   - Review threshold settings
   - Adjust evaluation periods
   - Validate metric collection

## Maintenance

### Regular Tasks
1. Review and update thresholds
2. Verify notification endpoints
3. Test failover triggers
4. Update documentation
5. Audit IAM permissions

## Emergency Response

### High Priority Alerts
1. CPU/Memory exhaustion
2. Storage capacity issues
3. Database connection limits
4. Health check failures

### Response Steps
1. Acknowledge alert
2. Assess impact
3. Execute runbook
4. Document resolution
5. Post-mortem review