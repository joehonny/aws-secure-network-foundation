locals {
  public_subnets = {
    a = {
      availability_zone = var.availability_zone_map["a"]
      cidr_block        = cidrsubnet(var.vpc_cidr, 2, 0)
    }
    b = {
      availability_zone = var.availability_zone_map["b"]
      cidr_block        = cidrsubnet(var.vpc_cidr, 2, 1)
    }
  }

  private_subnets = {
    a = {
      availability_zone = var.availability_zone_map["a"]
      cidr_block        = cidrsubnet(var.vpc_cidr, 2, 2)
    }
    b = {
      availability_zone = var.availability_zone_map["b"]
      cidr_block        = cidrsubnet(var.vpc_cidr, 2, 3)
    }
  }
}

# Intentional reference risk: workloads launched with a public-IP-capable
# interface can receive public IPv4 addresses in this tier. Exposure still
# requires routing and security policy; production use must be explicitly approved.
#trivy:ignore:AVD-AWS-0164
resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = var.vpc_id
  availability_zone       = each.value.availability_zone
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-public-${each.key}"
    Tier = "public"
  }
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id                  = var.vpc_id
  availability_zone       = each.value.availability_zone
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-private-${each.key}"
    Tier = "private"
  }
}
