output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs ordered by stable availability-zone key."
  value       = [for key in sort(keys(module.subnets.public_subnet_ids)) : module.subnets.public_subnet_ids[key]]
}

output "private_subnet_ids" {
  description = "Private subnet IDs ordered by stable availability-zone key."
  value       = [for key in sort(keys(module.subnets.private_subnet_ids)) : module.subnets.private_subnet_ids[key]]
}

output "security_group_ids" {
  description = "Example security-group IDs keyed by purpose."
  value       = module.security.security_group_ids
}
