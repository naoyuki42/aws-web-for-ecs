# クラスター
resource "aws_ecs_cluster" "cluster" {
  name = "${var.env}-ecs-cluster"
}

# タスク定義
resource "aws_ecs_task_definition" "task_definition" {
  family                   = "${var.env}-tas-definision"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./container/container_definition.json")
}

# サービス
resource "aws_ecs_service" "service" {
  name                              = "sevice"
  cluster                           = aws_ecs_cluster.cluster.arn
  task_definition                   = aws_ecs_task_definition.task_definition.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  platform_version                  = "1.3.0"
  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = false
    security_groups = [
      module.ecs_sg.security_group_id
    ]

    subnets = [
      aws_subnet.public_01.id,
      aws_subnet.public_02.id,
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "web"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }
}

# セキュリティグループ
module "ecs_sg" {
  source = "./modules/security_group"
  name   = "ecs-sg"
  vpc_id = aws_vpc.vpc.id
  port   = 80
  cidr_blocks = [
    aws_vpc.vpc.cidr_block
  ]
}
