mock_provider "aws" {}

run "two_availability_zone_contract" {
  command = plan

  variables {
    name_prefix        = "portfolio"
    vpc_cidr           = "10.40.0.0/16"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }

  assert {
    condition = (
      length(local.availability_zone_map) == 2 &&
      local.availability_zone_map["a"] == "us-east-1a" &&
      local.availability_zone_map["b"] == "us-east-1b"
    )
    error_message = "The network foundation must map the two configured availability zones to stable a and b keys."
  }
}

run "accepts_vpc_prefix_16_boundary" {
  command = plan

  variables {
    name_prefix        = "portfolio"
    vpc_cidr           = "10.40.0.0/16"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }
}

run "accepts_vpc_prefix_26_boundary" {
  command = plan

  variables {
    name_prefix        = "portfolio"
    vpc_cidr           = "10.40.0.0/26"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }
}

run "rejects_vpc_prefix_15" {
  command = plan

  variables {
    name_prefix        = "portfolio"
    vpc_cidr           = "10.40.0.0/15"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }

  expect_failures = [var.vpc_cidr]
}

run "rejects_vpc_prefix_27" {
  command = plan

  variables {
    name_prefix        = "portfolio"
    vpc_cidr           = "10.40.0.0/27"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }

  expect_failures = [var.vpc_cidr]
}

run "rejects_vpc_prefix_28" {
  command = plan

  variables {
    name_prefix        = "portfolio"
    vpc_cidr           = "10.40.0.0/28"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }

  expect_failures = [var.vpc_cidr]
}

run "rejects_malformed_vpc_cidr" {
  command = plan

  variables {
    name_prefix        = "portfolio"
    vpc_cidr           = "not-a-cidr"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }

  expect_failures = [var.vpc_cidr]
}

run "rejects_unspecified_address_range" {
  command = plan

  variables {
    name_prefix        = "portfolio"
    vpc_cidr           = "0.0.0.0/16"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }

  expect_failures = [var.vpc_cidr]
}

run "rejects_loopback_address_range" {
  command = plan

  variables {
    name_prefix        = "portfolio"
    vpc_cidr           = "127.0.0.0/16"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }

  expect_failures = [var.vpc_cidr]
}

run "rejects_link_local_address_range" {
  command = plan

  variables {
    name_prefix        = "portfolio"
    vpc_cidr           = "169.254.0.0/16"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }

  expect_failures = [var.vpc_cidr]
}

run "rejects_multicast_address_range" {
  command = plan

  variables {
    name_prefix        = "portfolio"
    vpc_cidr           = "224.0.0.0/16"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }

  expect_failures = [var.vpc_cidr]
}

run "rejects_wrong_availability_zone_count" {
  command = plan

  variables {
    name_prefix        = "portfolio"
    vpc_cidr           = "10.40.0.0/16"
    availability_zones = ["us-east-1a"]
  }

  expect_failures = [var.availability_zones]
}

run "rejects_duplicate_availability_zones" {
  command = plan

  variables {
    name_prefix        = "portfolio"
    vpc_cidr           = "10.40.0.0/16"
    availability_zones = ["us-east-1a", "us-east-1a"]
  }

  expect_failures = [var.availability_zones]
}

run "rejects_blank_availability_zone" {
  command = plan

  variables {
    name_prefix        = "portfolio"
    vpc_cidr           = "10.40.0.0/16"
    availability_zones = ["us-east-1a", " "]
  }

  expect_failures = [var.availability_zones]
}

run "four_subnet_key_contract" {
  command = plan

  variables {
    name_prefix        = "portfolio"
    vpc_cidr           = "10.40.0.0/16"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }

  assert {
    condition = (
      toset(keys(module.subnets.public_subnet_ids)) == toset(["a", "b"]) &&
      toset(keys(module.subnets.private_subnet_ids)) == toset(["a", "b"])
    )
    error_message = "Two availability zones must produce exactly four deterministic subnet keys."
  }
}

run "flow_logs_disabled_by_default" {
  command = plan

  variables {
    name_prefix        = "portfolio"
    vpc_cidr           = "10.40.0.0/16"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }

  assert {
    condition     = var.enable_flow_logs == false
    error_message = "Flow logs must remain disabled unless explicitly enabled."
  }
}

run "implemented_output_interfaces_are_stable" {
  command = apply

  variables {
    name_prefix        = "portfolio"
    vpc_cidr           = "10.40.0.0/16"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }

  assert {
    condition     = length(output.vpc_id) > 0 && can(tostring(output.vpc_id))
    error_message = "vpc_id must expose the implemented VPC identifier."
  }

  assert {
    condition = (
      length(output.public_subnet_ids) == 2 &&
      can(concat(output.public_subnet_ids, ["subnet-contract"]))
    )
    error_message = "public_subnet_ids must expose the two implemented public subnet identifiers through a list-compatible interface."
  }

  assert {
    condition = (
      length(output.private_subnet_ids) == 2 &&
      can(concat(output.private_subnet_ids, ["subnet-contract"]))
    )
    error_message = "private_subnet_ids must expose the two implemented private subnet identifiers through a list-compatible interface."
  }

  assert {
    condition = (
      length(output.security_group_ids) == 2 &&
      can(merge(output.security_group_ids, { contract = "sg-contract" }))
    )
    error_message = "security_group_ids must expose the implemented example security groups through a map-compatible interface."
  }
}
