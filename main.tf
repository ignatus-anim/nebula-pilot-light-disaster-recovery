provider "aws" {
  region = "eu-west-1"
  alias  = "primary"
}

provider "aws" {
  region = "us-east-1"
  alias  = "dr"
}
# Primary region configuration

# Primary vpc and networking
module "vpc" {
  source = "./modules/vpc"
  providers = {
    aws = aws.primary
  }
  vpc_cidr             = var.vpc_cidr
  environment          = var.environment
  region               = var.region
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}


module "alb" {
  source        = "./modules/alb"
  environment   = "primary"
  vpc_id        = module.vpc.vpc_id
  subnet_ids    = module.vpc.public_subnet_ids # Public subnets for ALB
  dr_subnet_ids = module.vpc.dr_public_subnet_ids
  dr_vpc_id     = module.vpc.dr_vpc_id
}

# Primary region compute resources
module "ec2" {
  source                   = "./modules/ec2"
  environment              = var.environment
  vpc_id                   = module.vpc.vpc_id            # From networking module
  subnet_ids               = module.vpc.public_subnet_ids # Public subnets
  instance_type            = "t2.micro"                   # Override default
  key_name                 = var.key_name
  target_group_arns        = [module.alb.target_group_arn]
  iam_instance_profile_arn = module.iam.ec2_instance_profile_arn
  s3_bucket_name           = module.s3.blog_bucket_id
  db_username              = module.rds.db_username
  db_password              = module.rds.db_password
  db_host                  = module.rds.primary_db_endpoint
  db_name                  = var.db_name
  region                   = var.region
  aws_access_key           = var.aws_access_key
  aws_secret_key           = var.aws_secret_key
  load_balancer_sg_id      = module.alb.alb_security_group_id
  dr-subnet_ids            = module.vpc.dr_public_subnet_ids
  dr_vpc_id                = module.vpc.dr_vpc_id
  dr_load_balancer_sg_id   = module.alb.dr_alb_security_group_id
  dr-target_group_arns     = [module.alb.dr_target_group_arn]
  dr_db_host               = module.rds.dr_replica_db_endpoint
  dr_s3_bucket_name        = module.s3.dr_s3_bucket_name
}

# Primary RDS instance
module "rds" {
  source                   = "./modules/rds"
  environment              = "primary"
  vpc_id                   = module.vpc.vpc_id
  private_subnet_ids       = module.vpc.private_subnet_ids
  database_engine          = "mysql"
  db_name                  = var.db_name
  ec2_security_group_id    = [module.ec2.security_group_id]
  dr_ec2_security_group_id = [module.ec2.dr_security_group_id]
  dr_private_subnet_ids    = module.vpc.dr_private_subnet_ids
  dr_vpc_id                = module.vpc.dr_vpc_id
}


module "s3" {
  source          = "./modules/s3"
  environment     = "primary"
  ec2_role_arn    = module.iam.ec2_role_arn
  dr_ec2_role_arn = module.iam.dr_ec2_role_arn
}

module "iam" {
  source         = "./modules/iam"
  environment    = "primary"
  s3_bucket_name = module.s3.blog_bucket_id
}

module "failover" {
  source                          = "./modules/failover"
  primary_instance_id             = module.ec2.primary_instance_id
  primary_alb_arn_suffix          = module.alb.primary_alb_arn_suffix
  primary_rds_identifier          = module.rds.primary_rds_identifier
  primary_target_group_arn_suffix = module.alb.primary_target_group_arn_suffix
  dr_asg_name                     = module.ec2.dr_asg_name
  dr_rds_identifier               = module.rds.dr_rds_identifier
  dr_s3_bucket_name               = module.s3.dr_s3_bucket_name
  account_id                      = var.account_id
}

module "global_accelerator" {
  source          = "./global_accelerator"
  primary_region  = var.region
  dr_region       = var.dr_region
  primary_alb_arn = module.alb.primary_alb_arn
  dr_alb_arn      = module.alb.dr_alb_arn
}