provider "aws" {
  region = "us-east-1"
  alias = "dr"
}

# Application Load Balancer
resource "aws_lb" "app_alb" {
  name               = "${var.environment}-app-alb"
  internal           = false  # Public-facing ALB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnet_ids  # Public subnets

  tags = {
    Environment = var.environment
  }
}

# Target group for ASG instances
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.environment}-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

# ALB listener (HTTP)
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}


# Application Load Balancer - DR region
resource "aws_lb" "dr-app_alb" {
  provider = aws.dr
  name               = "dr-app-alb"
  internal           = false  # Public-facing ALB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.dr-alb_sg.id]
  subnets            = var.dr_subnet_ids  # Public subnets

  tags = {
    Environment = "dr"
  }
}

# Target group for ASG instances
resource "aws_lb_target_group" "dr_app_tg" {
  provider = aws.dr
  name     = "dr-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.dr_vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

# ALB listener (HTTP)
resource "aws_lb_listener" "dr_app_listener" {
  provider = aws.dr
  load_balancer_arn = aws_lb.dr-app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dr_app_tg.arn
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.environment}-alb-sg"
  description = "Allow HTTP/HTTPS to ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for ALB in DR region
resource "aws_security_group" "dr-alb_sg" {
  name        = "${var.environment}-alb-sg"
  description = "Allow HTTP/HTTPS to ALB"
  provider = aws.dr
  vpc_id      = var.dr_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
