
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = var.enable_ec2 ? aws_instance.nebula_primary_instance[0].id : null
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = var.enable_ec2 ? aws_instance.nebula_primary_instance[0].private_ip : null
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = var.enable_ec2 ? aws_instance.nebula_primary_instance[0].public_ip : null
}


output "security_group_id" {
  description = "ID of the instance security group"
  value       = aws_security_group.ec2_sg.id
}

output "aws_ami_id" {
  value = var.enable_ec2 ? aws_ami_from_instance.primary_ami[0].id : null
}
