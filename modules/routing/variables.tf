variable "name_prefix" {
  description = "Prefix applied to route-table resource names."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC that owns the route tables."
  type        = string
}

variable "internet_gateway_id" {
  description = "Internet gateway used only by public default routes."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs keyed by stable availability-zone key."
  type        = map(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs keyed by stable availability-zone key."
  type        = map(string)
}
