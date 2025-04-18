# VPC Module
module "vpc" {
  source             = "../../modules/vpc"
  vpc_cidr           = var.vpc_cidr
  project_name       = var.project_name
  environment        = "${var.environment_name}-dr"
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  tags               = merge(var.tags, { DR = "true" })
}

# EC2 Module in DR Environment
# --------------------------
# DR region: Pilot light environment
# - Maintains stopped pilot light instance
# - Runs ASG with 0 capacity
# - Uses replicated AMIs from primary region

module "ec2" {
  source = "../../modules/ec2"

  # Boolean flags
  enable_ec2            = false
  enable_dr_pilot_light = true
  
  # Configuration
  project_name     = var.project_name
  environment_name = var.environment_name
  instance_type    = var.instance_type
  subnet_id = module.vpc.private_subnet_ids[0]
  subnet_ids       = module.vpc.private_subnet_ids
  key_pair_name    = var.key_pair_name
  vpc_id          = module.vpc.vpc_id
  tags            = var.tags
  db_password     = var.db_password
  asg_max_size    = var.asg_max_size
  region          = var.region
  dr_region       = var.dr_region
}

# RDS Module (DR)
module "rds" {
  source                = "../../modules/rds"
  project_name          = var.project_name
  environment_name      = var.environment_name
  db_engine            = var.db_engine
  engine_version       = var.engine_version
  instance_class       = var.db_instance_class
  allocated_storage    = var.allocated_storage
  db_username          = var.db_username
  db_password          = var.db_password
  multi_az             = var.multi_az
  storage_encrypted    = var.enable_encryption
  subnet_ids           = module.vpc.private_subnet_ids
  vpc_id               = module.vpc.vpc_id
  ec2_security_group_id = module.ec2.ec2_security_group_id
  region               = var.dr_region
  is_read_replica      = false
}

# SSM Module for storing database configuration
module "ssm" {
  source = "../../modules/ssm"

  project_name     = var.project_name
  environment_name = "${var.environment_name}-dr"
  db_username      = var.db_username
  db_password      = var.db_password
  db_endpoint      = module.rds.primary_db_endpoint  # Updated to use the correct output
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
    aws.primary = aws.primary_region
    aws.dr      = aws
  }

  project_name     = var.project_name
  environment_name = "${var.environment_name}-dr"
  region          = var.dr_region
  ia_days         = var.ia_days
  glacier_days    = var.glacier_days
  expiration_days = var.expiration_days
}
