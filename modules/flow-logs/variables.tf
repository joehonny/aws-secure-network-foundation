variable "name_prefix" {
  description = "Prefix applied to flow-log resource names."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to monitor."
  type        = string
}

variable "enabled" {
  description = "Whether to create CloudWatch Logs, IAM, and VPC flow-log resources."
  type        = bool
  default     = false
}

variable "retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.retention_days)
    error_message = "retention_days must be a CloudWatch Logs supported retention value."
  }
}
