# パラメーターグループ
resource "aws_db_parameter_group" "db_pg" {
  name   = "parametergroup${var.env}"
  family = "mysql5.7"

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}

# オプショングループ
resource "aws_db_option_group" "db_og" {
  name                 = "optiongroup${var.env}"
  engine_name          = "mysql"
  major_engine_version = "5.7"

  option {
    option_name = "MARIADB_AUDIT_PLUGIN"
  }
}

# サブネットグループ
resource "aws_db_subnet_group" "db_subnet" {
  name = "subnetgroup${var.env}"
  subnet_ids = [
    aws_subnet.private_01.id,
    aws_subnet.private_02.id
  ]
}

# DBインスタンス
resource "aws_db_instance" "db" {
  identifier                 = "${var.env}-db"
  engine                     = "mysql"
  engine_version             = "5.7.25"
  instance_class             = "db.t3.micro"
  allocated_storage          = 20
  max_allocated_storage      = 100
  storage_type               = "gp2"
  storage_encrypted          = true
  kms_key_id                 = data.aws_kms_alias.rds_key.arn
  username                   = "admin"
  password                   = "${var.db_pass}"
  multi_az                   = true
  publicly_accessible        = false
  backup_window              = "09:10-09:40"
  backup_retention_period    = 30
  maintenance_window         = "mon:10:10-mon:10:40"
  auto_minor_version_upgrade = false
  deletion_protection        = false
  skip_final_snapshot        = true
  port                       = 3306
  apply_immediately          = false
  vpc_security_group_ids = [
    module.mysql_sg.security_group_id
  ]
  parameter_group_name = aws_db_parameter_group.db_pg.name
  option_group_name    = aws_db_option_group.db_og.name
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name

  lifecycle {
    ignore_changes = [password]
  }
}

# DB用セキュリティグループ
module "mysql_sg" {
  source      = "./modules/security_group"
  name        = "mysql-sg"
  vpc_id      = aws_vpc.vpc.id
  port        = 3306
  cidr_blocks = [aws_vpc.vpc.cidr_block]
}

# バックアップ暗号化キー
data "aws_kms_alias" "rds_key" {
  name = "alias/aws/rds"
}
