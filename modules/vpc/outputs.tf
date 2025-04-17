# In your modules/vpc/outputs.tf
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.nebula_vpc.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.nebula_public_subnet[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.nebula_private_subnet[*].id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.nebula_vpc.cidr_block
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.nebula_igw.id
}
