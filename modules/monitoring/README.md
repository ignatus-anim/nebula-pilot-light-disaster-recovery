# Nebula DR Solution - Monitoring Module

## Overview
This module implements comprehensive monitoring for the Nebula DR solution, focusing on four critical components:
1. Application health and performance
2. EC2 instance metrics
3. RDS database operational metrics
4. Network connectivity and health

## Monitoring Strategy

### Application Monitoring
We monitor application health through two critical metrics:

1. **Application Latency** (5s threshold)
   - Tracks request latency via Application Load Balancer
   - Alerts when average latency exceeds 5 seconds for 15 minutes
   - Helps identify performance degradation
   - Uses ALB metrics

2. **Error Rate** (10 errors threshold)
   - Monitors HTTP 5XX errors
   - Alerts when error count exceeds 10 in 10 minutes
   - Critical for detecting application failures
   - Uses ALB metrics

### EC2 Instance Monitoring
We monitor EC2 instances for three critical metrics:

1. **CPU Utilization** (80% threshold)
   - Tracks processor usage using AWS native metrics
   - Alerts when CPU exceeds 80% for 10 minutes
   - Helps identify performance bottlenecks
   - No additional agent required

2. **Memory Usage** (80% threshold)
   - Monitors RAM utilization via CloudWatch agent
   - Alerts when memory exceeds 80% for 10 minutes
   - Critical for preventing application crashes
   - Requires CloudWatch agent installation

3. **Disk Usage** (85% threshold)
   - Tracks root volume storage utilization
   - Alerts when disk usage exceeds 85% for 10 minutes
   - Prevents system failures
   - Requires CloudWatch agent installation

### RDS Database Monitoring
We monitor RDS instances for five key metrics:

1. **CPU Utilization** (80% threshold)
   - Tracks database processor usage
   - Alerts when CPU exceeds 80% for 10 minutes
   - Uses built-in RDS metrics

2. **Storage Space** (10GB free space threshold)
   - Monitors available storage space
   - Alerts when free space falls below 10GB for 10 minutes
   - Uses built-in RDS metrics

3. **Connection Count** (100 connections threshold)
   - Tracks active database connections
   - Alerts when connections exceed 100 for 10 minutes
   - Uses built-in RDS metrics

4. **Replica Lag** (300 seconds threshold)
   - Monitors replication delay between primary and replica
   - Alerts when lag exceeds 5 minutes
   - Critical for DR readiness
   - Uses built-in RDS metrics

5. **Deadlocks** (5 deadlocks threshold)
   - Tracks database deadlock occurrences
   - Alerts when deadlocks exceed 5 in 10 minutes
   - Uses built-in RDS metrics

### Network Monitoring
We monitor network health through two metrics:

1. **Packet Loss** (1% threshold)
   - Tracks network packet loss via Network Load Balancer
   - Alerts when loss exceeds 1% for 15 minutes
   - Critical for network reliability
   - Uses NLB metrics

2. **VPC Status** (0 threshold)
   - Monitors VPC connectivity
   - Alerts on any connectivity issues
   - Uses VPC metrics

## Usage

```hcl
module "monitoring" {
  source = "../../modules/monitoring"

  project_name         = "my-project"
  environment_name     = "production"
  failover_lambda_arn  = "arn:aws:lambda:region:account:function:failover"
  
  # Instance IDs
  ec2_instance_id     = "i-1234567890abcdef0"
  rds_instance_id     = "db-instance-id"
  
  # Load Balancer Names
  alb_name            = "my-alb"
  nlb_name            = "my-nlb"
  
  # VPC ID
  vpc_id              = "vpc-1234567890abcdef0"
  
  # Optional: Override default thresholds
  application_latency_threshold = 5
  error_threshold             = 10
  cpu_utilization_threshold   = 80
  memory_utilization_threshold = 80
  disk_usage_threshold        = 85
  rds_cpu_threshold          = 80
  rds_storage_threshold      = 10000000000  # 10GB in bytes
  rds_connection_threshold   = 100
  replica_lag_threshold      = 300
  deadlock_threshold         = 5
  packet_loss_threshold      = 1
}
```

## Resources Created

### CloudWatch Alarms

#### Application Alarms
- Application Latency (`aws_cloudwatch_metric_alarm.application_latency_high`)
- Error Rate (`aws_cloudwatch_metric_alarm.application_5xx_errors`)

#### EC2 Alarms
- CPU Utilization (`aws_cloudwatch_metric_alarm.cpu_utilization_high`)
- Memory Usage (`aws_cloudwatch_metric_alarm.memory_utilization_high`)
- Disk Usage (`aws_cloudwatch_metric_alarm.disk_usage_high`)

#### RDS Alarms
- CPU Utilization (`aws_cloudwatch_metric_alarm.rds_cpu_utilization_high`)
- Storage Space (`aws_cloudwatch_metric_alarm.rds_free_storage_space_low`)
- Connection Count (`aws_cloudwatch_metric_alarm.rds_connection_count_high`)
- Replica Lag (`aws_cloudwatch_metric_alarm.rds_replica_lag`)
- Deadlocks (`aws_cloudwatch_metric_alarm.rds_deadlocks`)

#### Network Alarms
- Packet Loss (`aws_cloudwatch_metric_alarm.network_packet_loss`)
- VPC Status (`aws_cloudwatch_metric_alarm.vpc_status`)

### SNS Topics
- Monitoring Alerts (`aws_sns_topic.monitoring_alerts`)

## Requirements

### EC2 Instance Requirements
1. CloudWatch agent installation for memory and disk metrics
2. IAM role with CloudWatch permissions
3. Agent configuration for custom metrics

### RDS Requirements
1. Enhanced monitoring enabled
2. Appropriate IAM roles

### Network Requirements
1. Application Load Balancer configured
2. Network Load Balancer configured
3. VPC Flow Logs enabled

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Project identifier | `string` | n/a | yes |
| environment_name | Environment name | `string` | n/a | yes |
| failover_lambda_arn | Failover Lambda function ARN | `string` | n/a | yes |
| ec2_instance_id | EC2 instance ID | `string` | n/a | yes |
| rds_instance_id | RDS instance ID | `string` | n/a | yes |
| alb_name | Application Load Balancer name | `string` | n/a | yes |
| nlb_name | Network Load Balancer name | `string` | n/a | yes |
| vpc_id | VPC ID | `string` | n/a | yes |
| application_latency_threshold | Application latency threshold in seconds | `number` | `5` | no |
| error_threshold | Number of 5XX errors before alerting | `number` | `10` | no |
| cpu_utilization_threshold | EC2 CPU threshold percentage | `number` | `80` | no |
| memory_utilization_threshold | EC2 memory threshold percentage | `number` | `80` | no |
| disk_usage_threshold | EC2 disk usage threshold percentage | `number` | `85` | no |
| rds_cpu_threshold | RDS CPU threshold percentage | `number` | `80` | no |
| rds_storage_threshold | RDS free storage threshold in bytes | `number` | `10000000000` | no |
| rds_connection_threshold | RDS connection count threshold | `number` | `100` | no |
| replica_lag_threshold | Maximum acceptable RDS replica lag in seconds | `number` | `300` | no |
| deadlock_threshold | Number of deadlocks before alerting | `number` | `5` | no |
| packet_loss_threshold | Network packet loss threshold percentage | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| sns_topic_arn | ARN of the monitoring alerts SNS topic |
| sns_topic_name | Name of the monitoring alerts SNS topic |

## Alarm Configuration

### Application Monitoring

#### Application Latency
- **Metric**: TargetResponseTime (AWS/ApplicationELB)
- **Period**: 1 minute
- **Evaluation**: 15 consecutive periods
- **Action**: SNS notification

#### Error Rate
- **Metric**: HTTPCode_ELB_5XX_Count (AWS/ApplicationELB)
- **Period**: 1 minute
- **Evaluation**: 10 consecutive periods
- **Action**: SNS notification

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

#### Replica Lag
- **Metric**: ReplicationLag (AWS/RDS)
- **Period**: 5 minutes
- **Evaluation**: 2 consecutive periods
- **Action**: SNS notification

#### Deadlocks
- **Metric**: Deadlocks (AWS/RDS)
- **Period**: 10 minutes
- **Evaluation**: 1 period
- **Action**: SNS notification

### Network Monitoring

#### Packet Loss
- **Metric**: PacketLoss (AWS/NetworkELB)
- **Period**: 1 minute
- **Evaluation**: 15 consecutive periods
- **Action**: SNS notification

#### VPC Status
- **Metric**: StatusCheckFailed (AWS/EC2)
- **Period**: 5 minutes
- **Evaluation**: 1 period
- **Action**: SNS notification

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
