# AWSのリージョン名
variable "region" {
  default = "ap-northeast-1"
}

# プロジェクト名
variable "project" {
  default     = "Example"
  description = "project name"
}

# 環境名
variable "env" {
  default     = "TEST"
  description = "environment name"
}
