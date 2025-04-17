# DR Read Replica
resource "aws_db_instance" "nebula_read_replica" {
  count = var.environment_name == "dr" && var.is_read_replica ? 1 : 0
  identifier             = "${var.project_name}-dr-replica"
  replicate_source_db    = aws_db_instance.nebula_primary_db_instance[0].arn  # Use ARN for cross-region
  instance_class         = var.instance_class
  vpc_security_group_ids = [aws_security_group.rds_sg.id]  # Wrap in list brackets
  db_subnet_group_name   = aws_db_subnet_group.nebula_subnet_group.name
  storage_encrypted      = var.storage_encrypted
  skip_final_snapshot    = var.skip_final_snapshot
  publicly_accessible    = var.publicly_accessible
  auto_minor_version_upgrade = true
  tags = merge(var.tags, {
    Name = "${var.project_name}-read-replica"
    Environment = var.environment_name
    Region      = var.region
    Project     = var.project_name
    Type        = "ReadReplica"
  })

  lifecycle {
    ignore_changes = [replicate_source_db] # Prevent recreation if source changes
  }
}
