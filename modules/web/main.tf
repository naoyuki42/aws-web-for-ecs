# ECSクラスター
resource "aws_ecs_cluster" "web" {
  name = "${var.env}-web-server"

  tags = merge({
    Name = "${var.env}-ecs-cluster"
  })
}

# タスク定義
resource "aws_ecs_task_definition" "web" {
  family                   = "web"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  # TODO:読み込めるのはJSONファイルだけ
  container_definitions = file("${path.module}/container_definitions.json")

  tags = merge({
    Name = "${var.env}-ecs-task-definition"
  })
}

# サービス
resource "aws_ecs_service" "web" {
  name            = "web"
  cluster         = aws_ecs_cluster.web.arn
  task_definition = aws_ecs_task_definition.web.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  iam_role        = var.ecs_role_arn

  network_configuration {
    assign_public_ip = true
    security_groups  = [module.ecs_sg.security_group_id]

    subnets = var.subnet_ids
  }

  load_balancer {
    target_group_arn = var.alb_arn
    container_name   = "web"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  tags = merge({
    Name = "${var.env}-ecs-service"
  })
}

# セキュリティグループ
module "ecs_sg" {
  source      = "../security/security_group"
  name        = "esc-sg"
  vpc_id      = var.vpc_id
  port        = 80
  cidr_blocks = [var.cidr_block]
  env         = var.env
}
