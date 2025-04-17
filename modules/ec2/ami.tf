# AMI Management for Primary and DR Regions
# ----------------------------------------

# Base Ubuntu AMI (Available in both Primary and DR regions)
data "aws_ami" "ubuntu_22_04" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Latest DR AMI (Used in DR region only)
# Retrieved when enable_dr_pilot_light = true
data "aws_ami" "latest_dr_ami" {
  count       = var.enable_dr_pilot_light ? 1 : 0
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["${var.project_name}-dr-ami-*"]
  }

  filter {
    name   = "tag:DR"
    values = ["true"]
  }
}

# Primary AMI Creation (Created in Primary region only)
# Created when enable_ec2 = true
resource "aws_ami_from_instance" "primary_ami" {
  count              = var.enable_ec2 ? 1 : 0
  name               = "${var.project_name}-primary-ami-${formatdate("YYYYMMDD", timestamp())}"
  source_instance_id = aws_instance.nebula_primary_instance[0].id
  description        = "Daily AMI backup of primary instance for DR purposes"

  tags = merge(var.tags, {
    Name        = "${var.project_name}-primary-ami"
    Environment = var.environment_name
    Region      = var.region
    Project     = var.project_name
  })
}

# DR AMI Copy (Created in DR region only)
# Copies primary AMI to DR region when enable_ec2 = true
resource "aws_ami_copy" "dr_ami" {
  count             = var.enable_ec2 ? 1 : 0
  name              = "${var.project_name}-dr-ami-${formatdate("YYYYMMDD", timestamp())}"
  source_ami_id     = aws_ami_from_instance.primary_ami[0].id
  source_ami_region = var.region
  encrypted         = true
  description       = "DR copy of primary instance AMI"

  tags = merge(var.tags, {
    Name        = "${var.project_name}-dr-ami"
    Environment = "${var.environment_name}-dr"
    Region      = var.dr_region
    Project     = var.project_name
    DR          = "true"
  })
}