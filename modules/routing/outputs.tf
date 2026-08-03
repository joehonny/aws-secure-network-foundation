output "public_route_table_ids" {
  description = "Public route-table IDs keyed by stable availability-zone key."
  value       = { for key, route_table in aws_route_table.public : key => route_table.id }
}

output "private_route_table_ids" {
  description = "Private route-table IDs keyed by stable availability-zone key."
  value       = { for key, route_table in aws_route_table.private : key => route_table.id }
}

output "public_default_routes" {
  description = "Internet default-route destinations keyed by stable availability-zone key."
  value       = { for key, route in aws_route.public_internet : key => route.destination_cidr_block }
}
