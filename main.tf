# terraformのバージョン固定
terraform {
  required_version = "0.12.5"
}

# awsの設定
provider "aws" {
  version = "3.37.0"
  region  = var.region
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
}
