# ---------------------------------------------------------------------------------------------------------------------
# APPLICATION LOAD BALANCER
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_lb" "app" {
  name               = "${var.project_name}-${var.environment_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets           = var.subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment_name}-alb"
  }
}

# ALB Target Group
resource "aws_lb_target_group" "app" {
  name     = "${var.project_name}-${var.environment_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher            = "200"
    path               = "/health"
    port               = "traffic-port"
    timeout            = 5
    unhealthy_threshold = 2
  }
}

# ALB Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment_name}-alb-sg"
  description = "Security group for application load balancer"
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

  tags = {
    Name = "${var.project_name}-${var.environment_name}-alb-sg"
  }
}