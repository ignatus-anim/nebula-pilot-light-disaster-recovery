variable "vpc_cidr" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "public_subnets"{
    type = list(string)
}
variable "private_subnets"{
    type = list(string)
}

variable "availability_zones" {
  type = list(string)
}