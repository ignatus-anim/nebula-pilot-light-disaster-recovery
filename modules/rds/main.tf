
resource "aws_db_subnet_group" "nebula_subnet_group" {
  name        = "dr-db-subnet-group-${var.environment_name}"
  description = "Subnet group for RDS in ${var.environment_name} environment"
  subnet_ids  = var.subnet_ids

  tags = merge(
    {
      Name        = "dr-db-subnet-group-${var.environment_name}"
      Environment = var.environment_name
    },
    var.tags
  )
}



# Primary RDS Instance
resource "aws_db_instance" "nebula_primary_db_instance" {
  count = var.environment_name == "primary" ? 1 : 0
  identifier           = "${var.project_name}-primary"
  engine               = var.db_engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  allocated_storage    = var.allocated_storage
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.nebula_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]  # Wrap in list brackets
  skip_final_snapshot  = var.skip_final_snapshot
  publicly_accessible  = var.publicly_accessible
  storage_encrypted    = var.storage_encrypted
  multi_az             = var.multi_az

  tags = merge(var.tags, {
    Name = "${var.project_name}-primary-db"
    Environment = var.environment_name
    Region      = var.region
    Project     = var.project_name
  })
}
