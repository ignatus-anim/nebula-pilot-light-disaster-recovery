# Auto Scaling Group Configuration for DR
# -------------------------------------
# Created in DR region when enable_dr_pilot_light = true
# Initially set to 0 capacity for cost optimization
# Ready to scale up during DR events

resource "aws_autoscaling_group" "dr_asg" {
  count               = var.enable_dr_pilot_light ? 1 : 0
  name                = "${var.project_name}-${var.environment_name}-dr-asg"
  
  # Initial capacity configuration - starts at 0 for cost optimization
  min_size           = 0
  max_size           = var.asg_max_size
  desired_capacity   = 0
  
  # Health check configuration
  health_check_type          = "EC2"
  health_check_grace_period  = 300
  
  # Network configuration
  vpc_zone_identifier = var.subnet_ids

  # Launch configuration
  launch_template {
    id      = aws_launch_template.dr_launch_template[0].id
    version = "$Latest"  # Always use latest version to get newest AMI
  }

  # Instance refresh configuration
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
    }
  }

  # ASG instance naming
  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment_name}-dr-asg"
    propagate_at_launch = true
  }

  # Propagate all tags to ASG instances
  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value              = tag.value
      propagate_at_launch = true
    }
  }

  tag {
    key                 = "DR"
    value              = "true"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}
