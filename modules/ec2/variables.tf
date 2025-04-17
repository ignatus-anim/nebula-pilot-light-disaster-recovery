
variable "region" {
  type = string
}

# Removed ami_id variable - Using data source aws_ami.ubuntu_22_04 instead
# variable "ami_id" {
#   type = string
# }

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "key_pair_name" {
  type = string
}

variable "project_name" {
  type = string
}

variable "tags" {
  type = map(string)
}
variable "environment_name" {
  type = string
}

# Removed asg_min_size - Always using 0 for DR ASG
# variable "asg_min_size" {
#   type = number
# }

variable "subnet_ids" {
  description = "List of subnet IDs for the ASG"
  type        = list(string)
}

variable "asg_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  default     = 3
}

# Removed asg_desired_size - Always using 0 for DR ASG cost optimization
# variable "asg_desired_size" {
#   type = number
# }

variable "vpc_id" {
  type = string
}
variable "dr_region" {
  type = string
}

variable "db_password" {
  type        = string
  description = "Password for MySQL root user"
  sensitive   = true
}

variable "enable_ec2" {
  description = "Whether to create EC2 resources"
  type        = bool
  default     = true
}

variable "enable_dr_pilot_light" {
  description = "Whether to create DR ASG resources"
  type        = bool
  default     = false
}

# Removed dr_ami_id - Using data source aws_ami.latest_dr_ami instead
# variable "dr_ami_id" {
#   description = "AMI ID to use in DR region"
#   type        = string
#   default     = null
# }
