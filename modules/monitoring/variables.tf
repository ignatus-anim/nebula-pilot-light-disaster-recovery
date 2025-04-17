variable "project_name" {
  description = "Project identifier"
  type        = string
}

variable "environment_name" {
  description = "Environment name (e.g., production, staging)"
  type        = string
}

variable "health_check_id" {
  description = "Route53 health check ID"
  type        = string
}

variable "failover_lambda_arn" {
  description = "ARN of the failover Lambda function"
  type        = string
}

variable "ec2_instance_id" {
  description = "ID of the EC2 instance to monitor"
  type        = string
}

variable "rds_instance_id" {
  description = "ID of the RDS instance to monitor"
  type        = string
}

# Monitoring thresholds
variable "cpu_utilization_threshold" {
  description = "CPU utilization threshold percentage for alerts"
  type        = number
  default     = 80
}

variable "memory_utilization_threshold" {
  description = "Memory utilization threshold percentage for alerts"
  type        = number
  default     = 80
}

variable "disk_usage_threshold" {
  description = "Disk usage threshold percentage for alerts"
  type        = number
  default     = 85
}

variable "rds_cpu_threshold" {
  description = "RDS CPU threshold percentage for alerts"
  type        = number
  default     = 80
}

variable "rds_storage_threshold" {
  description = "RDS free storage threshold in bytes"
  type        = number
  default     = 10000000000  # 10GB in bytes
}

variable "rds_connection_threshold" {
  description = "RDS connection count threshold"
  type        = number
  default     = 100
}
