# Nebula - AWS Pilot Light Disaster Recovery Solution

## Overview
This repository contains the infrastructure-as-code implementation of a disaster recovery (DR) solution using the Pilot Light strategy on AWS. The solution ensures high availability of critical services (EC2, RDS, S3, and Lambda) with minimal overhead and quick recovery capabilities.

## Architecture
![Nebula DR Architecture](docs/diagrams/nebula-dr.png)

The solution implements a pilot light disaster recovery strategy across two AWS regions:
- **Primary Region**: Hosts the main production environment
- **DR Region**: Maintains minimal infrastructure that can be quickly scaled up during failover

### Core Components

#### 1. EC2 (Elastic Compute Cloud)
- Maintains stopped EC2 instances in DR region
- Uses Auto Scaling Groups for quick instance provisioning
- Regular AMI updates for consistent instance states

#### 2. RDS (Relational Database Service)
- Cross-region read replicas for database redundancy
- Automated backups and manual snapshots
- Quick promotion capability for read replicas

#### 3. S3 (Simple Storage Service)
- Cross-Region Replication (CRR) enabled
- Versioning enabled for data protection
- Lifecycle policies for cost optimization

#### 4. Lambda Functions
- Pre-deployed functions in DR region (disabled by default)
- Event source configurations ready for failover
- Configuration management via AWS Systems Manager

## Project Structure
```
├── docs/                    # Documentation files
├── envs/                    # Environment-specific configurations
│   ├── dr/                  # DR region configuration
│   └── primary/            # Primary region configuration
└── modules/                # Terraform modules
    ├── asg/                # Auto Scaling Group configuration
    ├── ec2/                # EC2 instance configuration
    ├── lambda/             # Lambda functions configuration
    ├── monitoring/         # CloudWatch monitoring setup
    ├── rds/                # RDS configuration
    ├── route53/            # DNS configuration
    └── s3/                 # S3 bucket configuration
```

## Prerequisites
- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- Access to two AWS regions
- Appropriate IAM permissions

## Deployment
1. Configure variables in `envs/primary/terraform.tfvars` and `envs/dr/terraform.tfvars`
2. Deploy primary region:
   ```bash
   cd envs/primary
   terraform init
   terraform plan
   terraform apply
   ```
3. Deploy DR region:
   ```bash
   cd ../dr
   terraform init
   terraform plan
   terraform apply
   ```

## Disaster Recovery Process
1. **Monitoring**: CloudWatch alarms monitor critical metrics
2. **Failover Trigger**: Automated or manual failover initiation
3. **Scale Up**: DR region resources are scaled up
4. **DNS Cutover**: Route 53 updates for traffic redirection
5. **Validation**: System health verification

Detailed runbook available in [docs/runbook.md](docs/runbook.md)

## Maintenance
- Regular testing of failover procedures
- AMI updates and patch management
- Backup verification
- DR documentation updates

## Cost Optimization
- Minimal resource usage in DR region
- Automated resource scaling
- Lifecycle policies for S3 data
- Cost monitoring and optimization recommendations

## Monitoring and Alerts
- CloudWatch dashboards for system health
- SNS notifications for critical events
- Regular replication lag monitoring
- Automated failover triggers

## Contributing
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License
[Specify your license here]

## Support
[Specify support contact information]