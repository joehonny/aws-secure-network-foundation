output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "internet_gateway_id" {
  description = "ID of the internet gateway attached to the VPC."
  value       = aws_internet_gateway.this.id
}

output "dns_support_enabled" {
  description = "Whether Amazon-provided DNS resolution is enabled."
  value       = aws_vpc.this.enable_dns_support
}

output "dns_hostnames_enabled" {
  description = "Whether DNS hostnames are enabled."
  value       = aws_vpc.this.enable_dns_hostnames
}
