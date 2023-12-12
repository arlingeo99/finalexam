output "rds_db_endpoint" {
  value = module.rds_module.db_endpoint
}

output "ec2_instance_ip" {
  value = module.ec2_module.public_ip
}

