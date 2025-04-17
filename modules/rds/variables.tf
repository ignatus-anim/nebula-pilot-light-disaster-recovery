variable "db_engine" {
  type = string
  default = "postgres"
}

variable "engine_version" {
  type = string
  default = "14.5"
}

variable "instance_class" {
  type = string
  default = "db.t4g.micro"
}

variable "allocated_storage" {
  type = number
  default = 20
}

variable "db_username" {
  type = string
  default = "admin"
}

variable "db_password" {
  type = string
  default = "MustBe12Char!"
}

variable "skip_final_snapshot" {
  type = bool
  default = true
}

variable "publicly_accessible" {
  type = bool
  default = false
}

variable "storage_encrypted" {
  type = bool
  default = true
}

variable "retention_period" {
  type = number
  default = 7
}

variable "deletion_window_in_days" {
  type = number
  default = 10
}

variable "enable_key_rotation" {
  type = bool
  default = true
}


# variable "security_group_id" {
#   type = string
# }

variable "multi_az" {
  type = bool
  default = false
}

variable "environment_name" {
  type = string
}
variable "region" {
  type = string
}

variable "project_name" {
  type = string
  default = "nebula"
}

variable "tags" {
  description = "A map of tags to apply to the resource"
  type        = map(string)
  default     = {}
}


variable "subnet_ids" {
  type = list(string)
}

variable "is_read_replica" {
  type = bool
}

variable "enable_cross_region_backup" {
  type = bool
  default = false
}

variable "ec2_security_group_id" {
  type = string
}

variable "vpc_id" {
  type = string
}