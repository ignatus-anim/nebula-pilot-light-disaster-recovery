# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr           = var.vpc_cidr
  project_name       = var.project_name
  environment        = var.environment_name
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  tags               = var.tags
}


# EC2 Module in Primary Environment
# -------------------------------
# Primary region: Active production environment
# - Runs active EC2 instance
# - Creates and copies AMIs to DR region
# - No DR resources created here

module "ec2" {
  source = "../../modules/ec2"

  # Boolean flags
  enable_ec2            = true  # Enable primary EC2 instance
  enable_dr_pilot_light = false # Disable DR resources in primary region

  # Configuration
  project_name     = var.project_name
  environment_name = var.environment_name
  instance_type    = var.instance_type
  subnet_id        = module.vpc.private_subnet_ids[0]
  subnet_ids       = module.vpc.private_subnet_ids # Added required subnet_ids attribute
  key_pair_name    = var.key_pair_name
  vpc_id           = module.vpc.vpc_id
  tags             = var.tags
  region           = var.primary_region
  dr_region        = var.dr_region
  asg_max_size     = var.asg_max_size
  db_password      = var.db_password
}

# RDS Module (Primary)
module "rds" {
  source                = "../../modules/rds"
  project_name          = var.project_name
  environment_name      = var.environment_name
  db_engine             = var.db_engine
  engine_version        = var.engine_version
  instance_class        = var.db_instance_class
  allocated_storage     = var.allocated_storage
  db_username           = var.db_username
  db_password           = var.db_password
  multi_az              = var.multi_az
  storage_encrypted     = var.enable_encryption
  subnet_ids            = module.vpc.private_subnet_ids
  ec2_security_group_id = module.ec2.security_group_id
  region                = var.primary_region
  vpc_id                = module.vpc.vpc_id
  is_read_replica       = false
}

# SSM Module for storing database configuration
module "ssm" {
  source = "../../modules/ssm"

  project_name     = var.project_name
  environment_name = var.environment_name
  db_username      = var.db_username
  db_password      = var.db_password
  db_endpoint      = module.rds.primary_db_endpoint # Updated to use the correct output
  depends_on       = [module.rds]
}

# Add outputs for the SSM parameter
output "database_config_parameter_name" {
  value = module.ssm.database_config_parameter_name
}

# S3 Module
module "s3" {
  source = "../../modules/s3"

  providers = {
    aws.primary = aws
    aws.dr      = aws.dr_region
  }

  project_name     = var.project_name
  environment_name = var.environment_name
  region           = var.primary_region
  ia_days          = var.ia_days
  glacier_days     = var.glacier_days
  expiration_days  = var.expiration_days
}

module "monitoring" {
  source = "../../modules/monitoring"

  project_name         = var.project_name
  health_check_id      = module.lambda.health_check_id
  failover_lambda_arn  = module.lambda.failover_lambda_arn
  ec2_instance_id = module.ec2.instance_id
  rds_instance_id = module.rds.db_instance_id
  environment_name     = var.environment_name
}
