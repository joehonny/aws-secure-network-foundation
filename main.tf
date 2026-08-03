module "vpc" {
  source = "./modules/vpc"

  name_prefix = var.name_prefix
  vpc_cidr    = var.vpc_cidr
}

module "subnets" {
  source = "./modules/subnets"

  name_prefix           = var.name_prefix
  vpc_id                = module.vpc.vpc_id
  vpc_cidr              = var.vpc_cidr
  availability_zone_map = local.availability_zone_map
}

module "routing" {
  source = "./modules/routing"

  name_prefix         = var.name_prefix
  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.vpc.internet_gateway_id
  public_subnet_ids   = module.subnets.public_subnet_ids
  private_subnet_ids  = module.subnets.private_subnet_ids
}

module "security" {
  source = "./modules/security"

  name_prefix = var.name_prefix
  vpc_id      = module.vpc.vpc_id
  vpc_cidr    = var.vpc_cidr
}

module "flow_logs" {
  source = "./modules/flow-logs"

  name_prefix = var.name_prefix
  vpc_id      = module.vpc.vpc_id
  enabled     = var.enable_flow_logs
}
