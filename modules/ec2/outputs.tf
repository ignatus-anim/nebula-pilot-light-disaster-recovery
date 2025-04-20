
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

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.app.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.app.dns_name
}

output "alb_name" {
  description = "Name of the Application Load Balancer"
  value       = aws_lb.app.name
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.app.arn
}

output "aws_ami_id" {
  description = "ID of the created AMI"
  value       = var.enable_ec2 ? aws_ami_from_instance.primary_ami[0].id : null
}

output "instance_role_arn" {
  description = "ARN of the EC2 instance IAM role"
  value       = aws_iam_role.ec2_role.arn
}

output "instance_profile_arn" {
  description = "ARN of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_profile.arn
}
