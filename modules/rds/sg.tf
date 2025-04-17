resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-${var.environment_name}-rds-sg"
  description = "Security group for RDS instances"
  vpc_id      = var.vpc_id

  # Allow MySQL/Aurora access from EC2 security group
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ec2_security_group_id]
    description     = "Allow MySQL access from EC2 instances"
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
    Name = "${var.project_name}-${var.environment_name}-rds-sg"
  })
}

