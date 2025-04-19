# Primary Environment - Nebula DR Solution

## Overview
The primary environment represents the main production infrastructure in the Nebula Disaster Recovery solution. It runs in the primary AWS region and hosts the active production workloads while maintaining synchronization with the DR environment.

## Architecture

### Environment Layout
```plaintext
Primary Region (eu-west-1)
├── VPC (10.0.0.0/16)
│   ├── Public Subnets
│   │   ├── ALB
│   │   └── NAT Gateways
│   └── Private Subnets
│       ├── EC2 Instances
│       └── RDS Database
├── S3 Buckets
│   └── Cross-region replication enabled
├── SSM Parameters
│   └── Database configuration
└── Monitoring
    ├── CloudWatch Alarms
    └── Health Checks
```

### Core Components

1. **VPC Infrastructure**
   - Dedicated VPC with public and private subnets
   - NAT Gateways for private subnet internet access
   - Internet Gateway for public access
   - Network ACLs and Security Groups

2. **Compute Layer (EC2)**
   - Active production EC2 instances
   - Application Load Balancer
   - Auto Scaling Group
   - Daily AMI creation and replication to DR region

3. **Database Layer (RDS)**
   - Primary RDS instance
   - Multi-AZ deployment
   - Automated backups
   - Cross-region snapshot replication

4. **Storage Layer (S3)**
   - Primary storage bucket
   - Lifecycle policies
   - Cross-region replication to DR bucket
   - Versioning enabled

5. **Parameter Store (SSM)**
   - Secure credential storage
   - Database configuration
   - Application parameters
   - Encrypted with KMS

6. **Monitoring**
   - Health checks
   - CloudWatch alarms
   - Failover triggers
   - Resource monitoring

## Configuration

### Provider Configuration
```hcl
provider "aws" {
  region = var.primary_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment_name
      Terraform   = "true"
    }
  }
}

provider "aws" {
  alias  = "dr_region"
  region = var.dr_region
  # DR region provider for cross-region operations
}
```

### Module Configuration Examples

1. **VPC Setup**
```hcl
module "vpc" {
  source             = "../../modules/vpc"
  vpc_cidr           = var.vpc_cidr
  project_name       = var.project_name
  environment        = var.environment_name
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  tags               = var.tags
}
```

2. **EC2 Configuration**
```hcl
module "ec2" {
  source              = "../../modules/ec2"
  enable_ec2          = true
  enable_dr_pilot_light = false
  project_name        = var.project_name
  environment_name    = var.environment_name
  instance_type       = var.instance_type
  subnet_id           = module.vpc.private_subnet_ids[0]
  subnet_ids          = module.vpc.private_subnet_ids
  key_pair_name       = var.key_pair_name
  vpc_id              = module.vpc.vpc_id
  tags                = var.tags
}
```

## Required Variables

| Name | Description | Type | Example |
|------|-------------|------|---------|
| `project_name` | Project identifier | `string` | "nebula" |
| `environment_name` | Environment name | `string` | "production" |
| `primary_region` | AWS primary region | `string` | "eu-west-1" |
| `dr_region` | AWS DR region | `string` | "us-east-1" |
| `vpc_cidr` | VPC CIDR block | `string` | "10.0.0.0/16" |
| `instance_type` | EC2 instance type | `string` | "t3.micro" |
| `db_instance_class` | RDS instance class | `string` | "db.t3.micro" |

## Outputs

| Name | Description |
|------|-------------|
| `database_config_parameter_name` | SSM parameter name for DB config |
| `vpc_id` | ID of the created VPC |
| `private_subnet_ids` | List of private subnet IDs |
| `public_subnet_ids` | List of public subnet IDs |

## Deployment

### Prerequisites
1. AWS CLI configured with appropriate credentials
2. Terraform >= 1.0.0
3. Required IAM permissions
4. S3 bucket for Terraform state (recommended)

### Deployment Steps
1. Initialize Terraform:
```bash
terraform init
```

2. Create `terraform.tfvars`:
```hcl
project_name     = "nebula"
environment_name = "production"
primary_region   = "eu-west-1"
dr_region        = "us-east-1"
vpc_cidr         = "10.0.0.0/16"
instance_type    = "t3.micro"
db_instance_class = "db.t3.micro"
```

3. Review the plan:
```bash
terraform plan
```

4. Apply the configuration:
```bash
terraform apply
```

## Maintenance and Operations

### Daily Operations
1. Monitor CloudWatch metrics
2. Check application health endpoints
3. Review security group rules
4. Monitor RDS performance
5. Verify backup completion

### Backup Procedures
1. Automated RDS snapshots
2. Cross-region AMI replication
3. S3 bucket replication
4. Configuration backups

### Security Considerations
1. All sensitive data in SSM Parameter Store
2. Encryption at rest enabled
3. Private subnets for sensitive resources
4. Security group restrictions
5. IAM roles with minimal permissions

### Cost Optimization
1. Right-sized instances
2. Automated instance scheduling
3. S3 lifecycle policies
4. RDS storage optimization
5. NAT Gateway optimization

## Related Documentation
- [DR Environment Configuration](../dr/README.md)
- [Recovery Strategy](../../docs/recovery_strategy.md)
- [Improvements Documentation](../../docs/improvements.md)
- [Module Documentation](../../modules/README.md)

## Troubleshooting

### Common Issues
1. **EC2 Instance Access**
   - Verify security group rules
   - Check SSH key pair
   - Confirm VPC routing

2. **Database Connectivity**
   - Verify security group rules
   - Check RDS status
   - Validate credentials in SSM

3. **Backup Verification**
   - Monitor CloudWatch events
   - Check S3 replication status
   - Verify AMI creation

### Health Check Failures
1. Review CloudWatch logs
2. Check application logs
3. Verify network connectivity
4. Validate security group rules