# General Variables
variable "project_name" {}
variable "environment_name" {}
variable "primary_region" {}
variable "dr_region" {}
variable "tags" {
  type    = map(string)
  default = {}
}

# VPC Variables
variable "vpc_cidr" {}
variable "public_subnets" {
  type = list(string)
}
variable "private_subnets" {
  type = list(string)
}
variable "availability_zones" {
  type = list(string)
}

# EC2 Variables
# Removed ami_id - Using data source in EC2 module
# variable "ami_id" {}
variable "instance_type" {}
variable "key_pair_name" {}

# Removed asg_min_size - Not needed as DR ASG always starts at 0
# variable "asg_min_size" {}
variable "asg_max_size" {}
# Removed asg_desired_size - Not needed as DR ASG always starts at 0
# variable "asg_desired_size" {}

# RDS Variables
variable "db_engine" {}
variable "engine_version" {}
variable "db_instance_class" {}
variable "allocated_storage" {}
variable "db_username" {}
variable "db_password" {}
variable "multi_az" {}
variable "enable_encryption" {}

# S3 Variables
variable "ia_days" {}
variable "glacier_days" {}
variable "expiration_days" {}

# # Backup and DR Variables
# variable "backup_retention_days" {}
# variable "deletion_window_in_days" {}
# variable "enable_key_rotation" {}

# # Security Variables
# variable "allowed_cidr_blocks" {
#   type = list(string)
# }

