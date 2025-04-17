
# Primary EC2 Instance Configuration
# --------------------------------
# Created in Primary region when enable_ec2 = true

resource "aws_instance" "nebula_primary_instance" {
  count         = var.enable_ec2 ? 1 : 0
  ami           = data.aws_ami.ubuntu_22_04.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_pair_name
  
  # Bootstrap configuration
  user_data     = base64encode(templatefile("${path.module}/user_data.sh", {
    project_name     = var.project_name
    environment_name = var.environment_name
    db_password      = var.db_password
  }))
  
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment_name}-ec2"
    Environment = var.environment_name
    Region      = var.region
    Project     = var.project_name
  })
}

# Remove the pilot_light_instance resource
