# AWSのリージョン名
variable "region" {
  default = "ap-northeast-1"
}

# プロジェクト名
variable "project" {
  default = "Test-Project"
}

# 環境名
variable "env" {
  default = "TEST"
}

# 取得ドメイン名
variable "domain" {
  default = "nao42.com"
}

# リクエスト制限用カスタムヘッダー
# キー
variable "header_key" {
  default = "x-custom-header"
}

# バリュー
variable "header_value" {
  default = "naoyuki42"
}
