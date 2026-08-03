output "security_group_ids" {
  description = "Example security-group IDs keyed by purpose."
  value = {
    internal_https = aws_security_group.internal_https.id
    outbound_https = aws_security_group.outbound_https.id
  }
}

output "internal_https_ingress_cidr" {
  description = "CIDR allowed by the internal HTTPS ingress rule."
  value       = aws_vpc_security_group_ingress_rule.internal_https.cidr_ipv4
}

output "internal_https_ingress_port" {
  description = "Port allowed by the internal HTTPS ingress rule."
  value       = aws_vpc_security_group_ingress_rule.internal_https.from_port
}
