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
