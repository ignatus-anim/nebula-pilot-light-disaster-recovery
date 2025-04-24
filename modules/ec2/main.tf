provider "aws" {
  region = "us-east-1"
  alias = "dr"
}

# EC2, ASG, launch templates

# Fetch the latest AMI if none is provided
data "aws_ami" "ubuntu" {
  count       = var.ami_id == null ? 1 : 0
  most_recent = true
  owners      = ["099720109477"]  # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Launch template for instances
resource "aws_launch_template" "app_lt" {
  name_prefix   = "primary-app-"
  image_id = coalesce(var.ami_id, data.aws_ami.ubuntu[0].id)
  instance_type = var.instance_type
  key_name = var.key_name

  # Docker setup and container run script
  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Install Docker
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo systemctl enable docker
              sudo systemctl start docker

              # Pull and run the app with environment variables
              sudo docker run -d \
                -e AWS_ACCESS_KEY=${var.aws_access_key} \
                -e AWS_SECRET_KEY=${var.aws_secret_key} \
                -e AWS_REGION=${var.region} \
                -e S3_BUCKET_NAME=${var.s3_bucket_name} \
                -e MYSQL_USER=${var.db_username} \
                -e MYSQL_PASSWORD=${var.db_password} \
                -e MYSQL_HOST=${var.db_host} \
                -e MYSQL_DB=${var.db_name} \
                -p 80:5000 \
                gideontee/flask-blog:latest
              EOF
  )

  iam_instance_profile {
    arn = var.iam_instance_profile_arn  # From IAM module
  }


  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.app_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment}-app-instance"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name                = "${var.environment}-app-asg"
  vpc_zone_identifier = var.subnet_ids
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.min_size

  target_group_arns = var.target_group_arns

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Environment"
    value               = "primary"
    propagate_at_launch = true
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "primary-app-instance"
  }
}

# Security group for instances
resource "aws_security_group" "app_sg" {
  name        = "${var.environment}-app-sg"
  description = "Allow HTTP/HTTPS and SSH"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = var.load_balancer_sg_id
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for dr instances
resource "aws_security_group" "dr-app_sg" {
  name        = "dr-app-sg"
  description = "Allow HTTP/HTTPS and SSH"
  vpc_id      = var.dr_vpc_id
  provider = aws.dr

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = var.dr_load_balancer_sg_id
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "dr" {
  provider = aws.dr
  name = "dr-asg"
  image_id = var.dr_ami_id
  instance_type = var.instance_type

  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Install Docker
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo systemctl enable docker
              sudo systemctl start docker

              # Pull and run the app with environment variables
              sudo docker run -d \
                -e AWS_ACCESS_KEY=${var.aws_access_key} \
                -e AWS_SECRET_KEY=${var.aws_secret_key} \
                -e AWS_REGION=${var.dr_region} \
                -e S3_BUCKET_NAME=${var.dr_s3_bucket_name} \
                -e MYSQL_USER=${var.db_username} \
                -e MYSQL_PASSWORD=${var.db_password} \
                -e MYSQL_HOST=${var.dr_db_host} \
                -e MYSQL_DB=${var.db_name} \
                -p 80:5000 \
                ignatusa3/blog-post-app:latest
              EOF
  )


  iam_instance_profile {
    arn = var.iam_instance_profile_arn  # From IAM module
  }


  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.dr-app_sg.id]
  }

}

# Auto Scaling Group for DR region
resource "aws_autoscaling_group" "dr-app_asg" {
  provider = aws.dr
  name                = "dr-app-asg"
  vpc_zone_identifier = var.dr-subnet_ids
  min_size            = 0
  max_size            = var.max_size
  desired_capacity    = 0

  target_group_arns = var.dr-target_group_arns

  launch_template {
    id      = aws_launch_template.dr.id
    version = "$Latest"
  }

  tag {
    key                 = "Environment"
    value               = "DR"
    propagate_at_launch = true
  }

}

resource "time_sleep" "wait_10_seconds" {
  depends_on = [aws_autoscaling_group.app_asg]
  create_duration = "10s"
}

data "aws_instance" "app_instance" {
  depends_on = [time_sleep.wait_10_seconds]

  filter {
    name   = "tag:Name"
    values = ["primary-app-instance"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}
