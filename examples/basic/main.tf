terraform {
  required_version = ">= 1.7.0"
}

module "network" {
  source = "../.."

  name_prefix        = "portfolio"
  vpc_cidr           = "10.40.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
  enable_flow_logs   = false
}

output "vpc_id" {
  description = "Reference VPC ID."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Reference public subnet IDs."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Reference private subnet IDs."
  value       = module.network.private_subnet_ids
}
