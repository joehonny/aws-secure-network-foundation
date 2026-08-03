variable "name_prefix" {
  description = "Lowercase prefix applied to named network resources."
  type        = string

  validation {
    condition = (
      length(var.name_prefix) >= 2 &&
      length(var.name_prefix) <= 32 &&
      can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.name_prefix))
    )
    error_message = "name_prefix must be 2 to 32 lowercase alphanumeric or hyphen characters, start with a letter, and end with a letter or number."
  }
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC. This four-subnet architecture supports prefix lengths from /16 through /26."
  type        = string
  default     = "10.40.0.0/16"

  validation {
    condition = try(
      cidrnetmask(var.vpc_cidr) != "" &&
      tonumber(split("/", var.vpc_cidr)[1]) >= 16 &&
      tonumber(split("/", var.vpc_cidr)[1]) <= 26 &&
      tonumber(split(".", split("/", var.vpc_cidr)[0])[0]) != 0 &&
      tonumber(split(".", split("/", var.vpc_cidr)[0])[0]) != 127 &&
      !(
        tonumber(split(".", split("/", var.vpc_cidr)[0])[0]) == 169 &&
        tonumber(split(".", split("/", var.vpc_cidr)[0])[1]) == 254
      ) &&
      !(
        tonumber(split(".", split("/", var.vpc_cidr)[0])[0]) >= 224 &&
        tonumber(split(".", split("/", var.vpc_cidr)[0])[0]) <= 239
      ),
      false,
    )
    error_message = "vpc_cidr must be a valid, AWS-permitted IPv4 CIDR block with a prefix length from /16 through /26 so four AWS-valid subnets can fit."
  }
}

variable "availability_zones" {
  description = "Exactly two unique AWS availability zones used for the redundant network layout."
  type        = list(string)

  validation {
    condition = (
      length(var.availability_zones) == 2 &&
      length(toset(var.availability_zones)) == 2 &&
      alltrue([for zone in var.availability_zones : length(trimspace(zone)) > 0])
    )
    error_message = "availability_zones must contain exactly two unique, non-empty AWS availability zone names."
  }
}

variable "enable_flow_logs" {
  description = "Whether to create VPC flow-log resources. Disabled by default to avoid unapproved logging cost."
  type        = bool
  default     = false
}

locals {
  availability_zone_map = zipmap(["a", "b"], var.availability_zones)
}
