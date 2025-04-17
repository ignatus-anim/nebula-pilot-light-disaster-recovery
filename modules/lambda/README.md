# Lambda Module - Nebula DR Solution

## Overview
This module manages AWS Lambda functions for both primary and DR regions, implementing a pilot light disaster recovery pattern. It includes primary application functions, DR functions (initially disabled), and failover orchestration capabilities.

## Architecture

### Primary Region
- Active Lambda functions for production workloads
- Environment-specific configurations
- CloudWatch logging and monitoring

### DR Region
- Pre-deployed Lambda functions (disabled)
- Failover orchestrator function
- Ready-to-enable event source mappings

## Features
- Primary/DR region function deployment
- Automated failover orchestration
- Cross-region configuration management
- IAM role and policy management
- Environment variable handling

## Usage

```hcl
module "lambda" {
  source = "../../modules/lambda"

  project_name    = "my-project"
  primary_region  = "eu-west-1"
  dr_region       = "us-east-1"
  is_dr_region    = false  # Set to true for DR deployment
  
  # Optional: RDS and ASG configuration for failover
  rds_instance_id = "my-rds-instance"
  asg_name        = "my-asg-name"
}
```

## Resources Created

### Primary Region
1. **Primary Lambda Function** (`aws_lambda_function.nebula_primary`)
   - Production workload function
   - Active state
   - Region-specific configuration

2. **IAM Roles and Policies**
   - Lambda execution role
   - Basic Lambda permissions
   - Custom service permissions

### DR Region
1. **DR Lambda Function** (`aws_lambda_function.dr`)
   - Disabled state (pilot light)
   - Mirrors primary function configuration
   - Ready for failover activation

2. **Failover Orchestrator** (`aws_lambda_function.failover_orchestrator`)
   - Manages DR activation
   - Handles RDS promotion
   - Controls ASG scaling
   - Cross-region operations

3. **IAM Roles and Policies**
   - Failover execution permissions
   - Cross-region access
   - Service-specific permissions

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Project identifier | `string` | n/a | yes |
| primary_region | Primary AWS region | `string` | n/a | yes |
| dr_region | DR AWS region | `string` | n/a | yes |
| is_dr_region | Deployment region flag | `bool` | n/a | yes |
| rds_instance_id | RDS instance identifier | `string` | n/a | no |
| asg_name | Auto Scaling Group name | `string` | n/a | no |

## Outputs

| Name | Description |
|------|-------------|
| primary_function_name | Primary Lambda function name |
| primary_function_arn | Primary Lambda function ARN |
| dr_function_name | DR Lambda function name |
| dr_function_arn | DR Lambda function ARN |
| lambda_role_arn | Lambda execution role ARN |

## Function Configurations

### Primary Lambda
```python
def handler(event, context):
    print("Lambda executed in Primary mode")
    return {"statusCode": 200}
```

### DR Lambda
```python
def handler(event, context):
    print("Lambda executed in DR mode")
    return {"statusCode": 200}
```

### Failover Orchestrator
```python
def lambda_handler(event, context):
    # Promote RDS read replica
    # Scale up DR ASG
    # Return failover status
```

## IAM Permissions

### Lambda Execution Role
- Basic Lambda execution
- CloudWatch Logs access
- Custom service permissions

### Failover Role
- RDS promotion permissions
- ASG management
- Cross-region operations

## Failover Process

1. **Trigger**
   - Health check failure
   - Manual activation
   - Automated response

2. **Orchestration**
   - RDS promotion
   - ASG scaling
   - Function activation

3. **Validation**
   - Health checks
   - Service verification
   - DNS updates

## Best Practices

### Development
1. **Code Management**
   - Use version control
   - Implement CI/CD
   - Regular testing

2. **Configuration**
   - Use environment variables
   - Implement secrets management
   - Region-specific settings

3. **Monitoring**
   - CloudWatch metrics
   - Error tracking
   - Performance monitoring

### Security
1. **IAM Permissions**
   - Least privilege access
   - Regular role review
   - Policy updates

2. **Environment Variables**
   - Sensitive data encryption
   - Region-specific values
   - Configuration validation

### DR Testing
1. **Regular Testing**
   - Failover simulation
   - Performance validation
   - Recovery time objectives

2. **Documentation**
   - Procedure updates
   - Configuration changes
   - Test results

## Troubleshooting

### Common Issues

1. **Function Deployment**
   - IAM role verification
   - Region configuration
   - Package dependencies

2. **Failover Process**
   - Permission checks
   - Service dependencies
   - Network connectivity

3. **Configuration**
   - Environment variables
   - Cross-region settings
   - Service endpoints

## Maintenance

### Regular Tasks
1. Review function configurations
2. Update dependencies
3. Test failover process
4. Audit permissions
5. Update documentation

### Updates
1. Code deployments
2. Configuration changes
3. Permission adjustments
4. Documentation updates

## Monitoring and Logging

### CloudWatch Metrics
- Invocation counts
- Error rates
- Duration metrics
- Memory usage

### Logs
- Function execution
- Failover events
- Error tracking
- Performance data

## Cost Optimization

1. **Function Configuration**
   - Memory allocation
   - Timeout settings
   - Concurrency limits

2. **DR Environment**
   - Disabled functions
   - Minimal configuration
   - Cost monitoring

## Security Considerations

1. **Access Control**
   - IAM roles
   - Resource policies
   - Network security

2. **Data Protection**
   - Environment variables
   - Cross-region data
   - Encryption settings

## Recovery Procedures

1. **Failover Activation**
   - Trigger identification
   - Process execution
   - Validation steps

2. **Service Restoration**
   - Health verification
   - Performance checks
   - Documentation updates