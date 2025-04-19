# VPC Module

## Overview
This module creates a complete AWS Virtual Private Cloud (VPC) infrastructure with public and private subnets spread across multiple availability zones. It includes all necessary networking components for a production-ready environment.

## Features
- VPC with customizable CIDR block
- Public and private subnets across multiple AZs
- Internet Gateway for public internet access
- NAT Gateways for private subnet internet access
- Route tables for public and private subnets
- Configurable DNS support and hostnames
- Consistent resource tagging

## Architecture

### Network Layout
```plaintext
VPC (10.0.0.0/16)
├── Public Subnet 1 (10.0.1.0/24) - AZ1
│   └── NAT Gateway 1
├── Public Subnet 2 (10.0.2.0/24) - AZ2
│   └── NAT Gateway 2
├── Private Subnet 1 (10.0.10.0/24) - AZ1
└── Private Subnet 2 (10.0.20.0/24) - AZ2
```

### Components
1. **VPC**
   - Custom CIDR block
   - DNS support enabled
   - DNS hostnames enabled

2. **Internet Gateway**
   - Attached to VPC
   - Enables internet access for public subnets

3. **Public Subnets**
   - Distributed across AZs
   - Auto-assign public IPs enabled
   - Route to Internet Gateway

4. **Private Subnets**
   - Distributed across AZs
   - No direct internet access
   - Route to NAT Gateway

5. **NAT Gateways**
   - One per AZ for high availability
   - Placed in public subnets
   - Elastic IPs attached

6. **Route Tables**
   - Public route table (routes through IGW)
   - Private route tables (routes through NAT)

## Usage

### Basic Example
```hcl
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr           = "10.0.0.0/16"
  project_name       = "my-project"
  environment        = "production"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.10.0/24", "10.0.20.0/24"]
  availability_zones = ["eu-west-1a", "eu-west-1b"]
  
  tags = {
    Environment = "production"
    Team        = "infrastructure"
  }
}
```

### With Custom Tags and CIDR
```hcl
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr           = "172.16.0.0/16"
  project_name       = "custom-project"
  environment        = "staging"
  public_subnets     = ["172.16.1.0/24", "172.16.2.0/24"]
  private_subnets    = ["172.16.10.0/24", "172.16.20.0/24"]
  availability_zones = ["eu-west-1a", "eu-west-1b"]
  
  tags = {
    Environment = "staging"
    Team        = "platform"
    CostCenter  = "platform-123"
    Terraform   = "true"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0.0 |

## Resources Created

| Resource | Description |
|----------|-------------|
| `aws_vpc.nebula_vpc` | Main VPC |
| `aws_internet_gateway.nebula_igw` | Internet Gateway |
| `aws_subnet.nebula_public_subnet` | Public subnets |
| `aws_subnet.nebula_private_subnet` | Private subnets |
| `aws_route_table.nebula_public_rt` | Public route table |
| `aws_route_table.nebula_private_rt` | Private route tables |
| `aws_nat_gateway.nebula_nat_gateway` | NAT Gateways |
| `aws_eip.nat_eip` | Elastic IPs for NAT Gateways |

## Variables

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `vpc_cidr` | CIDR block for VPC | `string` | Yes | - |
| `project_name` | Project identifier | `string` | Yes | - |
| `environment` | Environment name | `string` | Yes | - |
| `public_subnets` | List of public subnet CIDR blocks | `list(string)` | Yes | - |
| `private_subnets` | List of private subnet CIDR blocks | `list(string)` | Yes | - |
| `availability_zones` | List of availability zones | `list(string)` | Yes | - |
| `tags` | Resource tags | `map(string)` | No | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | The ID of the VPC |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `vpc_cidr_block` | The CIDR block of the VPC |
| `igw_id` | The ID of the Internet Gateway |
| `nat_gateway_ids` | List of NAT Gateway IDs |
| `public_route_table_id` | ID of the public route table |
| `private_route_table_ids` | List of private route table IDs |

## Best Practices
1. **CIDR Planning**
   - Use non-overlapping CIDR blocks
   - Plan for future expansion
   - Reserve space for additional subnets

2. **High Availability**
   - Deploy across multiple AZs
   - Use multiple NAT Gateways
   - Size subnets appropriately

3. **Security**
   - Use private subnets for sensitive resources
   - Implement Network ACLs as needed
   - Follow principle of least privilege

4. **Cost Optimization**
   - Monitor NAT Gateway usage
   - Clean up unused Elastic IPs
   - Right-size CIDR blocks

## Common Use Cases
1. **Application Infrastructure**
   - Web servers in public subnets
   - Databases in private subnets
   - Load balancers in public subnets

2. **Microservices Architecture**
   - Service mesh deployment
   - Container orchestration
   - API Gateway patterns

3. **Hybrid Connectivity**
   - VPN connections
   - Direct Connect
   - Transit Gateway integration

## Notes
1. NAT Gateways are created in public subnets
2. Each private subnet has its own route table
3. All resources are tagged consistently
4. DNS support is enabled by default
5. IPv6 is not enabled by default

## Related Modules
- EC2 Module
- RDS Module
- ECS Module
- Load Balancer Module