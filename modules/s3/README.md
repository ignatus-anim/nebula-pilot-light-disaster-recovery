# S3 Module Documentation

## Overview
This module manages S3 buckets for both primary and disaster recovery (DR) environments. It implements cross-region replication (CRR), versioning, and lifecycle policies for data protection and cost optimization.

## Features
- Primary and DR bucket creation with randomized suffixes
- Cross-region replication from primary to DR bucket
- Versioning enabled on both buckets
- Lifecycle policies for cost-effective storage management
- Automated transition to STANDARD_IA and GLACIER storage classes
- Configurable expiration rules

## Usage

```hcl
module "s3" {
  source = "../../modules/s3"
  
  project_name     = "my-project"
  environment_name = "production"
  region          = "eu-west-1"
  ia_days         = 90        # Optional: Days before transition to IA
  glacier_days    = 180       # Optional: Days before transition to Glacier
  expiration_days = 365       # Optional: Days before object deletion
}
```

## Resources Created

### Storage
- Primary S3 bucket (`aws_s3_bucket.nebula_primary_bucket`)
- DR S3 bucket (`aws_s3_bucket.nebula_dr_bucket`)
- Random suffix for bucket names (`random_id.bucket_suffix`)

### Data Protection
- Versioning for primary bucket (`aws_s3_bucket_versioning.nebula_primary_version`)
- Versioning for DR bucket (`aws_s3_bucket_versioning.nebula_dr_version`)
- Cross-region replication configuration (`aws_s3_bucket_replication_configuration.nebula_crr`)

### Lifecycle Management
- Lifecycle rules for primary bucket (`aws_s3_bucket_lifecycle_configuration.nebula_bucket_lifecycle`)
- Lifecycle rules for DR bucket (`aws_s3_bucket_lifecycle_configuration.nebula_dr_bucket_lifecycle`)

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_name` | Project identifier | `string` | `"nebula"` | no |
| `environment_name` | Environment name | `string` | - | yes |
| `region` | AWS region | `string` | - | yes |
| `ia_days` | Days before transition to STANDARD_IA | `number` | `90` | no |
| `glacier_days` | Days before transition to GLACIER | `number` | `180` | no |
| `expiration_days` | Days before object deletion | `number` | `365` | no |

## Outputs

| Name | Description |
|------|-------------|
| `primary_bucket_id` | The name of the primary S3 bucket |
| `primary_bucket_arn` | The ARN of the primary S3 bucket |
| `dr_bucket_id` | The name of the DR S3 bucket |
| `dr_bucket_arn` | The ARN of the DR S3 bucket |
| `replication_role_arn` | The ARN of the IAM role used for bucket replication |

## Lifecycle Rules

Objects in both primary and DR buckets follow this lifecycle:
1. Created as STANDARD storage class
2. Transition to STANDARD_IA after `ia_days` (default: 90 days)
3. Transition to GLACIER after `glacier_days` (default: 180 days)
4. Deletion after `expiration_days` (default: 365 days)

## Cross-Region Replication

- Enabled from primary to DR bucket
- Uses STANDARD storage class in destination
- Full bucket replication enabled
- Requires versioning on both buckets
- Automated replication of new objects

## Notes
1. Bucket names are automatically generated with random suffixes
2. Both buckets are created with versioning enabled
3. DR bucket is tagged with `DR = "true"`
4. Lifecycle rules are identical for both buckets
5. Cross-region replication is one-way (primary → DR)

## Best Practices
1. Monitor replication metrics and latency
2. Review lifecycle transitions regularly
3. Consider cost implications of storage classes
4. Implement appropriate bucket policies
5. Enable bucket logging if required