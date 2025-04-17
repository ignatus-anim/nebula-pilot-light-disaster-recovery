variable "project_name" {
  type = string
}

variable "tags" {
  type = list(string)
}

variable "primary_endpoint" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "dr_endpoint" {
  type = string
}

variable "dr_zone_id" {
  type = string
}