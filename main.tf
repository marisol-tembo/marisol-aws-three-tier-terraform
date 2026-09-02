terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "three-tier"
      ManagedBy = "terraform"
    }
  }
}

provider "random" {}

resource "random_password" "db" {
  length  = 16
  special = false
}

module "vpc" {
  source = "./modules/vpc"

  name       = var.name
  cidr_block = var.vpc_cidr_block
}

module "security" {
  source = "./modules/security"

  name   = var.name
  vpc_id = module.vpc.vpc_id
}

module "alb" {
  source = "./modules/alb"

  name                  = var.name
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
}

module "database" {
  source = "./modules/database"

  name                  = var.name
  private_db_subnet_ids = module.vpc.private_db_subnet_ids
  rds_security_group_id = module.security.rds_security_group_id
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = random_password.db.result
  instance_class        = var.db_instance_class
  multi_az              = var.db_multi_az
}

module "compute" {
  source = "./modules/compute"

  name                   = var.name
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
  app_security_group_id  = module.security.app_security_group_id
  target_group_arn       = module.alb.target_group_arn
  instance_type          = var.ec2_instance_type
  asg_min_size           = var.asg_min_size
  asg_max_size           = var.asg_max_size
  asg_desired_capacity   = var.asg_desired_capacity
  db_endpoint            = module.database.db_endpoint
  db_name                = var.db_name
  db_username            = var.db_username
  db_password            = random_password.db.result
}

module "monitoring" {
  source = "./modules/monitoring"

  name                    = var.name
  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  asg_name                = module.compute.asg_name
  db_instance_id          = module.database.db_instance_id
}
