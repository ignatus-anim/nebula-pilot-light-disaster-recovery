variable "project_name" {
  type = string
}

variable "environment_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_endpoint" {
  type        = string
  description = "RDS instance endpoint"
}
