# Automated backup sharing to DR region
resource "aws_db_instance_automated_backups_replication" "cross_region" {
  count = var.environment_name == "primary" && var.enable_cross_region_backup ? 1 : 0
  source_db_instance_arn = aws_db_instance.nebula_primary_db_instance[0].arn
  retention_period       = var.retention_period
  kms_key_id            = aws_kms_key.nebula_dr_backups[0].arn
}

