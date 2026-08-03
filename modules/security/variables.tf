variable "name_prefix" {
  description = "Prefix applied to security-group resource names."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC that owns the security groups."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC IPv4 CIDR used to restrict internal HTTPS ingress."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}
