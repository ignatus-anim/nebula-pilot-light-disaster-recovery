resource "aws_kms_key" "nebula_dr_backups" {
  count = var.environment_name == "primary" && var.enable_cross_region_backup ? 1 : 0
  description             = "KMS key for DR backups"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
}