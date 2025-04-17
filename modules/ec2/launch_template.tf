# Launch Template Configuration for DR ASG
# --------------------------------------
# Created in DR region when enable_dr_pilot_light = true
# Defines instance configuration for ASG-launched instances

resource "aws_launch_template" "dr_launch_template" {
  count         = var.enable_dr_pilot_light ? 1 : 0
  name_prefix   = "${var.project_name}-${var.environment_name}-dr-template-"
  
  # Uses latest DR AMI if available, falls back to Ubuntu AMI
  image_id      = var.enable_dr_pilot_light ? (
    length(data.aws_ami.latest_dr_ami) > 0 ? data.aws_ami.latest_dr_ami[0].id : data.aws_ami.ubuntu_22_04.id
  ) : null
  
  instance_type = var.instance_type

  # Network configuration
  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [aws_security_group.ec2_sg.id]
  }

  # Bootstrap configuration
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    project_name     = var.project_name
    environment_name = var.environment_name
    db_password      = var.db_password
  }))

  # Instance tagging configuration
  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.project_name}-${var.environment_name}-dr-instance"
      DR   = "true"
    })
  }

  # Update launch template when new AMI is available
  lifecycle {
    create_before_destroy = true
  }
}
