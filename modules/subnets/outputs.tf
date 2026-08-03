output "public_subnet_ids" {
  description = "Public subnet IDs keyed by stable availability-zone key."
  value       = { for key, subnet in aws_subnet.public : key => subnet.id }
}

output "private_subnet_ids" {
  description = "Private subnet IDs keyed by stable availability-zone key."
  value       = { for key, subnet in aws_subnet.private : key => subnet.id }
}

output "public_subnet_cidrs" {
  description = "Public subnet CIDRs keyed by stable availability-zone key."
  value       = { for key, subnet in aws_subnet.public : key => subnet.cidr_block }
}

output "private_subnet_cidrs" {
  description = "Private subnet CIDRs keyed by stable availability-zone key."
  value       = { for key, subnet in aws_subnet.private : key => subnet.cidr_block }
}

output "public_ipv4_assignment" {
  description = "Public IPv4 auto-assignment setting for each public subnet."
  value       = { for key, subnet in aws_subnet.public : key => subnet.map_public_ip_on_launch }
}

output "private_ipv4_assignment" {
  description = "Public IPv4 auto-assignment setting for each private subnet."
  value       = { for key, subnet in aws_subnet.private : key => subnet.map_public_ip_on_launch }
}
