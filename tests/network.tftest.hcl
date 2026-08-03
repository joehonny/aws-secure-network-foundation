mock_provider "aws" {
  override_data {
    target = module.flow_logs.data.aws_caller_identity.current[0]
    values = {
      account_id = "123456789012"
      arn        = "arn:aws:iam::123456789012:user/terraform-test"
      id         = "123456789012"
      user_id    = "AIDATEST"
    }
  }

  override_data {
    target = module.flow_logs.data.aws_partition.current[0]
    values = {
      dns_suffix         = "amazonaws.com"
      id                 = "aws"
      partition          = "aws"
      reverse_dns_prefix = "com.amazonaws"
    }
  }

  override_data {
    target = module.flow_logs.data.aws_region.current[0]
    values = {
      description = "US East (N. Virginia)"
      endpoint    = "ec2.us-east-1.amazonaws.com"
      id          = "us-east-1"
      name        = "us-east-1"
      region      = "us-east-1"
    }
  }

  override_resource {
    target = module.flow_logs.aws_cloudwatch_log_group.this[0]
    values = {
      arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vpc-flow-logs/portfolio"
    }
  }

  override_resource {
    target = module.flow_logs.aws_iam_role.this[0]
    values = {
      arn = "arn:aws:iam::123456789012:role/portfolio-vpc-flow-logs-test"
      id  = "portfolio-vpc-flow-logs-test"
    }
  }

  override_resource {
    target = module.flow_logs.aws_flow_log.this[0]
    values = {
      id = "fl-test"
    }
  }
}

run "builds_deterministic_isolated_network" {
  command = apply

  variables {
    name_prefix        = "portfolio"
    vpc_cidr           = "10.40.0.0/26"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }

  assert {
    condition = (
      module.vpc.dns_support_enabled &&
      module.vpc.dns_hostnames_enabled
    )
    error_message = "The VPC must enable DNS resolution and DNS hostnames."
  }

  assert {
    condition = module.subnets.public_subnet_cidrs == {
      a = "10.40.0.0/28"
      b = "10.40.0.16/28"
    }
    error_message = "A /26 VPC must yield the two stable public /28 subnets."
  }

  assert {
    condition = module.subnets.private_subnet_cidrs == {
      a = "10.40.0.32/28"
      b = "10.40.0.48/28"
    }
    error_message = "A /26 VPC must yield the two stable private /28 subnets without overlap."
  }

  assert {
    condition = (
      alltrue(values(module.subnets.public_ipv4_assignment)) &&
      !anytrue(values(module.subnets.private_ipv4_assignment))
    )
    error_message = "Only public subnets may auto-assign public IPv4 addresses."
  }

  assert {
    condition = (
      length(module.routing.public_route_table_ids) == 2 &&
      length(module.routing.private_route_table_ids) == 2 &&
      alltrue([for destination in values(module.routing.public_default_routes) : destination == "0.0.0.0/0"])
    )
    error_message = "Each public subnet must have an internet default route and each private subnet must have an isolated route table."
  }

  assert {
    condition = (
      module.security.internal_https_ingress_cidr == "10.40.0.0/26" &&
      module.security.internal_https_ingress_port == 443 &&
      module.security.internal_https_ingress_cidr != "0.0.0.0/0"
    )
    error_message = "The example ingress rule must allow HTTPS only from inside the VPC."
  }

  assert {
    condition = (
      length(output.vpc_id) > 0 &&
      length(output.public_subnet_ids) == 2 &&
      length(output.private_subnet_ids) == 2 &&
      length(output.security_group_ids) == 2
    )
    error_message = "Root outputs must expose real VPC, subnet, and security-group results."
  }
}

run "flow_logs_remain_absent_by_default" {
  command = apply

  variables {
    name_prefix        = "portfolio"
    vpc_cidr           = "10.40.0.0/16"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }

  assert {
    condition = (
      module.flow_logs.flow_log_id == null &&
      module.flow_logs.log_group_arn == null &&
      module.flow_logs.iam_role_arn == null
    )
    error_message = "Flow-log, log-group, and IAM resources must remain absent by default."
  }
}

run "flow_logs_use_scoped_cloudwatch_delivery_role" {
  command = apply

  variables {
    name_prefix        = "portfolio"
    vpc_cidr           = "10.40.0.0/16"
    availability_zones = ["us-east-1a", "us-east-1b"]
    enable_flow_logs   = true
  }

  assert {
    condition = (
      module.flow_logs.flow_log_id != null &&
      module.flow_logs.log_group_retention_days == 30 &&
      strcontains(module.flow_logs.assume_role_policy, "aws:SourceAccount") &&
      strcontains(module.flow_logs.assume_role_policy, "123456789012") &&
      strcontains(module.flow_logs.assume_role_policy, "arn:aws:ec2:us-east-1:123456789012:vpc-flow-log/*")
    )
    error_message = "Enabled flow logs must use CloudWatch retention and confused-deputy protections in the delivery-role trust policy."
  }

  assert {
    condition = (
      module.flow_logs.delivery_policy_json != null &&
      length(jsondecode(module.flow_logs.delivery_policy_json).Statement) == 2 &&
      length([
        for statement in jsondecode(module.flow_logs.delivery_policy_json).Statement : statement
        if statement.Sid == "WriteToDedicatedLogGroup"
      ]) == 1 &&
      length(one([
        for statement in jsondecode(module.flow_logs.delivery_policy_json).Statement : statement
        if statement.Sid == "WriteToDedicatedLogGroup"
      ]).Action) == 2 &&
      toset(one([
        for statement in jsondecode(module.flow_logs.delivery_policy_json).Statement : statement
        if statement.Sid == "WriteToDedicatedLogGroup"
      ]).Action) == toset(["logs:CreateLogStream", "logs:PutLogEvents"]) &&
      one([
        for statement in jsondecode(module.flow_logs.delivery_policy_json).Statement : statement
        if statement.Sid == "WriteToDedicatedLogGroup"
      ]).Resource == "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vpc-flow-logs/portfolio:*" &&
      length([
        for statement in jsondecode(module.flow_logs.delivery_policy_json).Statement : statement
        if statement.Sid == "DescribeLogDelivery"
      ]) == 1 &&
      length(one([
        for statement in jsondecode(module.flow_logs.delivery_policy_json).Statement : statement
        if statement.Sid == "DescribeLogDelivery"
      ]).Action) == 2 &&
      toset(one([
        for statement in jsondecode(module.flow_logs.delivery_policy_json).Statement : statement
        if statement.Sid == "DescribeLogDelivery"
      ]).Action) == toset(["logs:DescribeLogGroups", "logs:DescribeLogStreams"]) &&
      one([
        for statement in jsondecode(module.flow_logs.delivery_policy_json).Statement : statement
        if statement.Sid == "DescribeLogDelivery"
      ]).Resource == "*"
    )
    error_message = "The flow-log delivery policy must contain exactly the scoped write and describe statements, with no additional statements, actions, or resources."
  }
}
