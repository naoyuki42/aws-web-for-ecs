# terraformのバージョン固定
terraform {
  required_version = "0.12.5"
}

# awsの設定
provider "aws" {
  version = "3.37.0"
  region  = var.region
  # TODO:タグが付いていないリソースあり
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.env
    }
  }
}

# ネットワークの設定
module "network" {
  source = "./modules/network"
  env    = var.env
  domain = var.domain
}

# webサーバーの設定
module "web" {
  source     = "./modules/web"
  env        = var.env
  vpc_id     = module.network.vpc_id
  cidr_block = module.network.vpc_cidr_block
  subnet_ids = [
    module.network.public_subnet_01_id,
    module.network.public_subnet_02_id
  ]
  alb_arn      = module.network.alb_arn
  ecs_role_arn = module.security.ecs_role_arn
}

# セキュリティの設定
module "security" {
  source = "./modules/security"
}
