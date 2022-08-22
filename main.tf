# terraformのバージョン固定
terraform {
  required_version = "0.12.5"
}

# awsの設定
provider "aws" {
  version = "3.37.0"
  region  = var.region
}

# TODO:リソースのタグ付け
# TODO:リソースのモジュール化
# TODO:複数環境への対応
