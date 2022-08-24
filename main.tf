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
# TODO:WAFの導入
# TODO:ログの取得
# TODO:変数などにdescriptionの追加
# TODO:ECSのサービスを複数にしたい（APIと管理画面）
# TODO:CI/CDパイプラインの追加
# TODO:セッションマネージャーの導入
# TODO:webサーバーの命名の修正（APIとADMIN）
