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
variable "instance_type" {}
variable "key_pair_name" {}
variable "db_password" {}
variable "asg_max_size" {}
variable "region" {}

# RDS Variables
variable "db_engine" {}
variable "engine_version" {}
variable "db_instance_class" {}
variable "allocated_storage" {}
variable "db_username" {}
variable "db_password" {}
variable "multi_az" {}
variable "enable_encryption" {}

# Removed redundant variables that are handled by the module or not needed:
# - ami_id (using data source)
# - asg_min_size (always 0)
# - asg_desired_size (always 0)
# - pilot_light_instance_type (using ASG instead)

# Commented out unused variables
# # S3 Variables
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

