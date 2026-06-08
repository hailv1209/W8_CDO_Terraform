module "vpc" {
  source = "./modules/vpc"

  project              = var.project
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  enable_nat_gateway   = var.enable_nat_gateway
}

module "security_groups" {
  source = "./modules/security-groups"

  project                 = var.project
  vpc_id                  = module.vpc.vpc_id
  region                  = var.aws_region
  public_route_table_id   = module.vpc.public_route_table_id
  private_subnet_ids      = module.vpc.private_subnet_ids
}

module "rds" {
  source = "./modules/rds"

  project               = var.project
  db_instance_class     = var.db_instance_class
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  db_allocated_storage  = var.db_allocated_storage
  private_subnet_ids   = module.vpc.private_subnet_ids
  security_group_id    = module.security_groups.rds_security_group_id
}

module "s3" {
  source = "./modules/s3"

  project = var.project
}

module "ec2" {
  source = "./modules/ec2"

  project           = var.project
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  public_subnet_id  = module.vpc.public_subnet_ids[0]
  security_group_id = module.security_groups.web_security_group_id
  db_host           = module.rds.rds_endpoint
  db_name           = var.db_name
  db_user           = var.db_username
  db_password       = var.db_password
  s3_bucket_name    = module.s3.s3_bucket_name
}
