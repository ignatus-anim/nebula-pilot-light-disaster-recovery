# EC2 Module Documentation

## Overview
This module manages EC2 instances and related resources for both primary and disaster recovery (DR) environments using an Auto Scaling Group (ASG) based architecture. It also includes an Application Load Balancer (ALB) for distributing traffic and enabling health monitoring.

## Architecture
- **Primary Region**: Runs active production EC2 instance with ALB
- **DR Region**: Maintains zero-capacity ASG with latest AMI configuration
- **AMI Management**: Automated daily AMI creation and cross-region replication
- **Auto Scaling**: Pre-configured ASG in DR region (initially scaled to 0)
- **Load Balancing**: Internet-facing ALB with security group isolation

## Resources Created

### Primary Region (`enable_ec2 = true`)
1. **Application Load Balancer** (`aws_lb.app`)
   - Internet-facing ALB
   - HTTP listener on port 80
   - Health check configuration (/health endpoint)
   - Security group with public HTTP access
   - Target group for EC2 instances

2. **EC2 Instance** (`aws_instance.nebula_primary_instance`)
   - Ubuntu 22.04 base AMI
   - Deployed in private subnet
   - Bootstrapped via user_data script
   - Tagged for environment tracking
   - IAM instance profile attached
   - Security group with restricted access

3. **Security Groups**
   - **ALB Security Group** (`aws_security_group.alb`)
     - Allows inbound HTTP (80) from internet
     - Allows all outbound traffic
     - Tagged for environment tracking
   
   - **EC2 Security Group** (`aws_security_group.ec2_sg`)
     - Allows inbound SSH (22) from specified CIDR blocks
     - Allows inbound HTTP (80) only from ALB security group
     - Allows all outbound traffic
     - Tagged for environment tracking

4. **AMI Automation**
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

## Security Architecture

### Network Security
1. **ALB Layer**
   - Public-facing load balancer
   - HTTP (80) open to internet
   - Deployed across multiple AZs
   - Health checks enabled

2. **Application Layer**
   - EC2 instances in private subnets
   - HTTP access only from ALB
   - SSH access configurable (restrict in production)
   - All outbound traffic allowed

### Security Groups
1. **ALB Security Group**
   ```hcl
   Inbound:
   - HTTP (80) from 0.0.0.0/0
   Outbound:
   - All traffic to 0.0.0.0/0
   ```

2. **EC2 Security Group**
   ```hcl
   Inbound:
   - HTTP (80) from ALB security group
   - SSH (22) from specified CIDR blocks
   Outbound:
   - All traffic to 0.0.0.0/0
   ```

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
  subnet_ids            = ["subnet-456", "subnet-789"]  # For ALB
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
| `subnet_ids` | List of subnet IDs for ALB and DR ASG | `list(string)` | Yes |
| `key_pair_name` | SSH key pair name | `string` | Yes |
| `vpc_id` | VPC ID | `string` | Yes |
| `region` | AWS region | `string` | Yes |
| `dr_region` | DR region | `string` | Yes |
| `tags` | Resource tags | `map(string)` | No |

## Outputs

| Name | Description |
|------|-------------|
| `instance_id` | ID of primary EC2 instance |
| `instance_private_ip` | Private IP of primary instance |
| `instance_public_ip` | Public IP of primary instance |
| `ec2_security_group_id` | ID of EC2 security group |
| `alb_security_group_id` | ID of ALB security group |
| `aws_ami_id` | ID of created AMI |
| `dr_asg_name` | Name of DR Auto Scaling Group |
| `alb_dns_name` | DNS name of the Application Load Balancer |

## Security Recommendations
1. Restrict SSH CIDR blocks in production
2. Implement HTTPS with ACM certificates
3. Enable AWS WAF on ALB for additional security
4. Regular security group audit
5. Monitor and log ALB access
6. Implement instance connect for SSH access

## Notes
1. Primary instance uses Ubuntu 22.04 as base AMI
2. DR region uses ASG with 0 capacity for cost optimization
3. AMIs are automatically created daily at 1 AM UTC
4. ALB provides HTTP access and health monitoring
5. CloudWatch logging enabled via IAM role
6. AMI encryption enforced in DR region
7. Consider implementing AMI retention policies
8. Monitor AMI-related costs regularly
