module "vpc" {
  source = "./modules/vpc"

  name       = "three-tier"
  cidr_block = "10.0.0.0/16"
}
