resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-${var.environment_name}-ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = var.vpc_id

  # Allow SSH inbound
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider restricting this in production
    description = "Allow SSH access"
  }

  # Allow HTTP inbound
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP access"
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment_name}-ec2-sg"
  })
}

# Output the security group ID for use by RDS
output "ec2_security_group_id" {
  value = aws_security_group.ec2_sg.id
}
