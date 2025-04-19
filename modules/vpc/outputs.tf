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

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.nebula_nat_gateway[*].id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.nebula_public_rt.id
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = aws_route_table.nebula_private_rt[*].id
}
