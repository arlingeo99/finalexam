provider "aws" {
  region = "us-east-1"
}

module "vpc_module" {
  source = "./modules/VPC"
}

module "rds_module" {
  source = "./modules/RDS"

  depends_on = [module.vpc_module]

  vpc_id                 = module.vpc_module.vpc_id
  vpc_public_subnet_1_id = module.vpc_module.vpc_public_subnet_1_id
  vpc_public_subnet_2_id = module.vpc_module.vpc_public_subnet_2_id
}

module "ec2_module" {
  source = "./modules/EC2"

  depends_on = [module.vpc_module, module.rds_module]

  vpc_id           = module.vpc_module.vpc_id
  public_subnet_id = module.vpc_module.vpc_public_subnet_1_id
}
