output "flow_log_id" {
  description = "VPC flow-log ID, or null when flow logs are disabled."
  value       = try(aws_flow_log.this[0].id, null)
}

output "log_group_arn" {
  description = "CloudWatch log-group ARN, or null when flow logs are disabled."
  value       = try(aws_cloudwatch_log_group.this[0].arn, null)
}

output "iam_role_arn" {
  description = "Flow-log delivery-role ARN, or null when flow logs are disabled."
  value       = try(aws_iam_role.this[0].arn, null)
}

output "log_group_retention_days" {
  description = "CloudWatch log retention, or null when flow logs are disabled."
  value       = try(aws_cloudwatch_log_group.this[0].retention_in_days, null)
}

output "assume_role_policy" {
  description = "Flow-log delivery-role trust policy, or null when flow logs are disabled."
  value       = try(aws_iam_role.this[0].assume_role_policy, null)
}

output "delivery_policy_json" {
  description = "Flow-log CloudWatch delivery policy JSON, or null when flow logs are disabled."
  value       = try(aws_iam_role_policy.this[0].policy, null)
}
