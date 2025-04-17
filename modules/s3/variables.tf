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

variable "ia_days" {
  type = number
  default = 90
}

variable "glacier_days" {
  type = number
  default = 180
}

variable "expiration_days" {
  type = number
  default = 365
}

variable "tags" {
  description = "A map of tags to apply to resources"
  type        = map(string)
  default     = {}
}
