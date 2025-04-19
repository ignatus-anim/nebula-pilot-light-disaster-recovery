# SSM (Systems Manager) Module

## Overview
This module manages AWS Systems Manager Parameter Store resources for securely storing and managing configuration data, particularly database credentials and connection information. It's a critical component of our infrastructure that enables secure parameter management across primary and DR environments.

## Purpose
The SSM module serves several key purposes:

1. **Secure Configuration Storage**
   - Stores sensitive database credentials
   - Manages connection strings
   - Centralizes configuration management
   - Enables secure parameter access

2. **DR Readiness**
   - Maintains separate parameters for DR environment
   - Enables quick configuration switching during failover
   - Ensures configuration consistency across regions
   - Supports automated DR procedures

3. **Access Control**
   - Implements least-privilege access
   - Manages parameter permissions
   - Controls configuration visibility
   - Supports role-based access

## Resources Created

### Parameter Store Entries
1. **Database Configuration Parameter** (`aws_ssm_parameter.database_config`)
   - Type: SecureString (automatically encrypted)
   - Path: /${project_name}/${environment_name}/database
   - Contains:
     - Database username
     - Database password
     - Database endpoint
   - Format: JSON-encoded string

### Parameter Naming Convention
- Primary Environment: `/${project_name}/${environment_name}/database`
- DR Environment: `/${project_name}/${environment_name}-dr/database`

## Usage

### Basic Implementation
```hcl
module "ssm" {
  source = "../../modules/ssm"

  project_name     = "my-project"
  environment_name = "production"
  db_username      = var.db_username
  db_password      = var.db_password
  db_endpoint      = module.rds.primary_db_endpoint
}
```

### DR Environment Implementation
```hcl
module "ssm" {
  source = "../../modules/ssm"

  project_name     = "my-project"
  environment_name = "production-dr"
  db_username      = var.db_username
  db_password      = var.db_password
  db_endpoint      = module.rds.primary_db_endpoint
}
```

## Integration Points

### 1. EC2 Integration
- EC2 instances access database credentials via SSM
- Requires IAM role with SSM permissions
- Uses AWS SDK for parameter retrieval
- Supports automatic credential rotation

### 2. RDS Integration
- Stores RDS endpoint information
- Manages database credentials
- Enables dynamic configuration updates
- Supports multi-region database setup

### 3. DR Failover Integration
- Maintains DR-specific parameters
- Enables quick configuration switching
- Supports automated failover procedures
- Ensures configuration consistency

## Security Considerations

### 1. Encryption
- All sensitive parameters stored as SecureString
- Automatic encryption using AWS KMS
- Region-specific encryption keys
- Encryption in transit and at rest

### 2. Access Control
- IAM-based access control
- Path-based permissions
- Role-based access management
- Least privilege principle

### 3. Audit Trail
- Parameter version history
- CloudTrail integration
- Access logging
- Change tracking

## Benefits

### 1. Security
- Centralized credential management
- Encrypted parameter storage
- Fine-grained access control
- Audit capabilities

### 2. Operational Efficiency
- Simplified configuration management
- Reduced manual intervention
- Automated parameter access
- Consistent parameter naming

### 3. DR Support
- Cross-region parameter management
- Failover readiness
- Configuration consistency
- Automated DR procedures

## Variables

| Name | Description | Type | Required |
|------|-------------|------|----------|
| project_name | Project identifier | string | yes |
| environment_name | Environment name | string | yes |
| db_username | Database username | string | yes |
| db_password | Database password | string | yes |
| db_endpoint | RDS instance endpoint | string | yes |

## Outputs

| Name | Description |
|------|-------------|
| database_config_parameter_name | SSM parameter name for database config |
| database_config_parameter_arn | SSM parameter ARN |
| database_config_version | SSM parameter version |

## Best Practices

1. **Parameter Naming**
   - Use consistent naming conventions
   - Include environment identifiers
   - Follow hierarchical structure
   - Use descriptive names

2. **Access Management**
   - Implement least privilege
   - Regular permission reviews
   - Use IAM roles
   - Monitor access patterns

3. **DR Considerations**
   - Maintain DR-specific parameters
   - Regular parameter validation
   - Test parameter access
   - Document parameter usage

4. **Maintenance**
   - Regular parameter reviews
   - Version tracking
   - Clean up unused parameters
   - Monitor parameter usage

## Notes
1. Parameters are automatically encrypted using AWS KMS
2. Parameter names follow AWS-recommended hierarchical structure
3. DR environment parameters include "-dr" suffix
4. All parameters are created as SecureString type
5. Parameter versions are tracked automatically
6. CloudWatch logging is enabled for parameter access
7. Cross-region parameter access is supported
8. Regular parameter rotation is recommended