output "Load_balancer_dns" {
  value = module.alb.alb_dns_name
}

output "RDS_endpoint" {
  value = module.rds.primary_db_endpoint
}

output "DR_bucket_arn" {
  value = module.s3.dr_bucket_arn
}

output "Global_Accelerator_dns_name" {
  value = module.global_accelerator.global_accelerator_dns_name
}