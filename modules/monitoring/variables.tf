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

variable "application_latency_threshold" {
  description = "Application latency threshold in seconds"
  type        = number
  default     = 5
}

variable "error_threshold" {
  description = "Number of 5XX errors before alerting"
  type        = number
  default     = 10
}

variable "packet_loss_threshold" {
  description = "Network packet loss threshold percentage"
  type        = number
  default     = 1
}

variable "replica_lag_threshold" {
  description = "Maximum acceptable RDS replica lag in seconds"
  type        = number
  default     = 300
}

variable "deadlock_threshold" {
  description = "Number of deadlocks before alerting"
  type        = number
  default     = 5
}

variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
}

# variable "nlb_name" {
#   description = "Name of the Network Load Balancer"
#   type        = string
# }

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}
