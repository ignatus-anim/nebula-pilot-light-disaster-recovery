# RDS Module Documentation

## Overview
This module manages RDS (Relational Database Service) instances for both primary and disaster recovery (DR) environments. It supports cross-region backup replication and read replicas as part of the disaster recovery strategy.

## Architecture

### Primary Region Components
1. **Primary RDS Instance**
   - MySQL/PostgreSQL database instance
   - Encrypted storage
   - Automated backups
   - Multi-AZ deployment option
   - Custom subnet group
   - Secure network access via security groups

2. **Backup Configuration**
   - Cross-region backup replication
   - KMS encryption for backups
   - Configurable retention period
   - Automated backup sharing to DR region

### DR Region Components
1. **Read Replica Configuration**
   - Cross-region read replica capability
   - Promotion-ready for failover
   - Identical instance specifications
   - Independent security groups

2. **Security**
   - Dedicated security group for database access
   - Encryption at rest using KMS
   - Network isolation in private subnets
   - EC2 security group integration

## Resources Created

### Networking
- **Subnet Group** (`aws_db_subnet_group.nebula_subnet_group`)
  - Spans multiple availability zones
  - Private subnet placement
  - Environment-specific naming

### Database Instances
- **Primary Instance** (`aws_db_instance.nebula_primary_db_instance`)
  - Conditional creation based on environment
  - Configurable instance specifications
  - Automated backup configuration
  - Multi-AZ support

- **Read Replica** (`aws_db_instance.nebula_read_replica`)
  - Cross-region replication support
  - Automated minor version upgrades
  - Independent security configuration
  - Lifecycle management for source changes

### Security
- **Security Group** (`aws_security_group.rds_sg`)
  - Inbound rules for database port (3306)
  - Source security group from EC2 instances
  - All outbound traffic allowed
  - Environment-specific tagging

### Encryption
- **KMS Key** (`aws_kms_key.nebula_dr_backups`)
  - Cross-region backup encryption
  - Automatic key rotation
  - Configurable deletion window
  - DR-specific key management

## Usage

### Primary Region Configuration
```hcl
module "rds" {
  source            = "../../modules/rds"
  project_name      = "nebula"
  environment_name  = "primary"
  db_engine         = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  db_username       = "admin"
  db_password       = "securepassword"
  multi_az          = true
  storage_encrypted = true
  subnet_ids        = ["subnet-1", "subnet-2"]
  vpc_id            = "vpc-123"
  region            = "eu-west-1"
  is_read_replica   = false
  enable_cross_region_backup = true
  ec2_security_group_id = "sg-123"
}
```

### DR Region Configuration
```hcl
module "rds" {
  source            = "../../modules/rds"
  project_name      = "nebula"
  environment_name  = "dr"
  instance_class    = "db.t3.micro"
  subnet_ids        = ["subnet-3", "subnet-4"]
  vpc_id            = "vpc-456"
  region            = "us-east-1"
  is_read_replica   = true
  ec2_security_group_id = "sg-456"
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project_name` | Project identifier | `string` | `"nebula"` | No |
| `environment_name` | Environment name | `string` | - | Yes |
| `db_engine` | Database engine type | `string` | `"postgres"` | No |
| `engine_version` | Engine version | `string` | `"14.5"` | No |
| `instance_class` | Instance type | `string` | `"db.t4g.micro"` | No |
| `allocated_storage` | Storage size in GB | `number` | `20` | No |
| `db_username` | Database admin username | `string` | `"admin"` | No |
| `db_password` | Database admin password | `string` | - | Yes |
| `multi_az` | Enable Multi-AZ deployment | `bool` | `false` | No |
| `storage_encrypted` | Enable storage encryption | `bool` | `true` | No |
| `subnet_ids` | List of subnet IDs | `list(string)` | - | Yes |
| `vpc_id` | VPC ID | `string` | - | Yes |
| `is_read_replica` | Enable read replica | `bool` | - | Yes |
| `enable_cross_region_backup` | Enable backup replication | `bool` | `false` | No |
| `ec2_security_group_id` | EC2 security group ID | `string` | - | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `primary_db_endpoint` | Primary instance endpoint |
| `primary_db_arn` | Primary instance ARN |
| `db_instance_id` | Database instance ID |

## Security Considerations
1. Database instances are deployed in private subnets
2. Access is restricted to EC2 instances via security groups
3. Storage encryption is enabled by default
4. Cross-region backups are encrypted using KMS
5. Credentials are managed securely via variables

## Backup and Recovery
1. Automated backups are enabled by default
2. Cross-region backup replication for DR
3. Read replicas can be promoted during failover
4. Configurable backup retention period
5. KMS encryption for backup security

## Notes
1. Multi-AZ deployment recommended for production
2. Consider instance class based on workload
3. Monitor storage usage and scale as needed
4. Regular testing of DR promotion procedures
5. Review security group rules periodically