variable "name_prefix" {
  description = "Prefix applied to subnet resource names."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC that owns the subnets."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC IPv4 CIDR block divided into four equal subnets."
  type        = string

  validation {
    condition = try(
      can(cidrnetmask(var.vpc_cidr)) &&
      tonumber(split("/", var.vpc_cidr)[1]) >= 16 &&
      tonumber(split("/", var.vpc_cidr)[1]) <= 26,
      false,
    )
    error_message = "vpc_cidr must be a valid IPv4 CIDR with a prefix length from /16 through /26."
  }
}

variable "availability_zone_map" {
  description = "Stable a and b keys mapped to two distinct availability zones."
  type        = map(string)

  validation {
    condition = (
      toset(keys(var.availability_zone_map)) == toset(["a", "b"]) &&
      length(toset(values(var.availability_zone_map))) == 2
    )
    error_message = "availability_zone_map must contain distinct a and b availability zones."
  }
}
