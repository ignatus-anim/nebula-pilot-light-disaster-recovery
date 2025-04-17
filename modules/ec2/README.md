# EC2 Module Documentation

## Overview
This module manages EC2 instances and related resources for both primary and disaster recovery (DR) environments using an Auto Scaling Group (ASG) based architecture.

## Architecture
- **Primary Region**: Runs active production EC2 instance
- **DR Region**: Maintains zero-capacity ASG with latest AMI configuration
- **AMI Management**: Automated daily AMI creation and cross-region replication
- **Auto Scaling**: Pre-configured ASG in DR region (initially scaled to 0)

## Resources Created

### Primary Region (`enable_ec2 = true`)
1. **EC2 Instance** (`aws_instance.nebula_primary_instance`)
   - Ubuntu 22.04 base AMI
   - Deployed in private subnet
   - Bootstrapped via user_data script
   - Tagged for environment tracking
   - IAM instance profile attached
   - Security group with SSH/HTTP access

2. **AMI Automation**
   - **Systems Manager Document** (`aws_ssm_document.create_ami`)
     - Defines AMI creation workflow
     - Handles cross-region replication
     - Configures AMI encryption
     - Manages AMI tagging

   - **EventBridge Rule** (`aws_cloudwatch_event_rule.daily_ami`)
     - Triggers daily at 1 AM UTC
     - Executes SSM automation
     - Creates fresh AMI from primary instance
     - Replicates to DR region automatically

   - **IAM Roles and Policies**
     - EventBridge execution role
     - AMI creation permissions
     - Cross-region copy permissions

### DR Region (`enable_dr_pilot_light = true`)
1. **Auto Scaling Group** (`aws_autoscaling_group.dr_asg`)
   - Initially set to 0 capacity
   - Configured across multiple AZs
   - Uses latest DR AMI
   - Ready for immediate scale-up during failover

2. **Launch Template** (`aws_launch_template.dr_launch_template`)
   - Uses latest replicated DR AMI
   - Consistent instance configuration
   - User data for bootstrap
   - Security group configuration
   - Instance tagging

### Security
- Security group with inbound rules:
  - SSH (port 22)
  - HTTP (port 80)
- IAM role with CloudWatch permissions
- Encrypted AMIs in DR region

## AMI Management

### Automated AMI Creation
The module includes an automated AMI management system that:
1. Creates daily backups of the primary instance
2. Replicates AMIs to the DR region
3. Maintains consistent naming and tagging
4. Handles encryption during replication

#### AMI Creation Schedule
- **Frequency**: Daily at 1 AM UTC
- **Retention**: Latest AMI always available
- **Naming Convention**: `{project_name}-primary-ami-{YYYYMMDD}`
- **DR Copy**: `{project_name}-dr-ami-{YYYYMMDD}`

## Usage

### Primary Region Configuration
```hcl
module "ec2" {
  source                = "../../modules/ec2"
  enable_ec2            = true
  enable_dr_pilot_light = false
  
  project_name          = "project-name"
  environment_name      = "production"
  instance_type         = "t2.micro"
  subnet_id             = "subnet-123"
  key_pair_name         = "my-key-pair"
  vpc_id                = "vpc-123"
  region                = "eu-west-1"
  dr_region             = "us-east-1"
}
```

### DR Region Configuration
```hcl
module "ec2" {
  source                = "../../modules/ec2"
  enable_ec2            = false
  enable_dr_pilot_light = true
  
  project_name          = "project-name"
  environment_name      = "production"
  instance_type         = "t2.micro"
  subnet_ids            = ["subnet-456", "subnet-789"]
  key_pair_name         = "my-key-pair"
  vpc_id                = "vpc-456"
  region                = "us-east-1"
  dr_region             = "us-east-1"
  asg_max_size          = 3
}
```

## Variables

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `enable_ec2` | Enable primary EC2 instance creation | `bool` | Yes |
| `enable_dr_pilot_light` | Enable DR ASG resources | `bool` | Yes |
| `project_name` | Project identifier | `string` | Yes |
| `environment_name` | Environment name | `string` | Yes |
| `instance_type` | EC2 instance type | `string` | Yes |
| `subnet_id` | Subnet ID for primary instance | `string` | Yes |
| `subnet_ids` | List of subnet IDs for DR ASG | `list(string)` | Yes |
| `key_pair_name` | SSH key pair name | `string` | Yes |
| `vpc_id` | VPC ID | `string` | Yes |
| `region` | AWS region | `string` | Yes |
| `dr_region` | DR region | `string` | Yes |
| `db_password` | Database password for bootstrap | `string` | Yes |
| `tags` | Resource tags | `map(string)` | Yes |
| `asg_max_size` | Maximum size for DR ASG | `number` | No |

## Outputs

| Name | Description |
|------|-------------|
| `instance_id` | ID of primary EC2 instance |
| `instance_private_ip` | Private IP of primary instance |
| `instance_public_ip` | Public IP of primary instance |
| `security_group_id` | ID of EC2 security group |
| `aws_ami_id` | ID of created AMI |
| `dr_asg_name` | Name of DR Auto Scaling Group |

## DR Failover Process

### Automated Failover
1. Update ASG desired capacity to 1
2. ASG launches new instance using latest DR AMI
3. Instance bootstraps using user_data script
4. Health checks confirm instance readiness

### Best Practices
1. Monitor ASG events via CloudWatch
2. Regularly test DR failover process
3. Review and update launch template configuration
4. Maintain current AMIs through automated process
5. Monitor costs during DR testing

### Troubleshooting
1. Check CloudWatch Logs for ASG events
2. Verify launch template configuration
3. Confirm AMI availability in DR region
4. Review security group rules
5. Check IAM permissions for ASG/EC2

## Notes
1. Primary instance uses Ubuntu 22.04 as base AMI
2. DR region uses ASG with 0 capacity for cost optimization
3. AMIs are automatically created daily at 1 AM UTC
4. Security group allows SSH and HTTP access by default
5. CloudWatch logging enabled via IAM role
6. AMI encryption enforced in DR region
7. Consider implementing AMI retention policies
8. Monitor AMI-related costs regularly
