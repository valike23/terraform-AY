# main.tf

# Reference an existing VPC and subnets
data "aws_vpc" "existing_vpc" {
  id = var.vpc_id
}

data "aws_subnet_ids" "existing_subnets" {
  vpc_id = data.aws_vpc.existing_vpc.id
}

data "aws_subnet" "selected_subnet" {
  count = length(data.aws_subnet_ids.existing_subnets.ids)
  id    = data.aws_subnet_ids.existing_subnets.ids[count.index]
}

# Create ECS cluster
resource "aws_ecs_cluster" "my_ecs_cluster" {
  name = local.cluster_name
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "my_task" {
  family                   = local.task_family
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = <<DEFINITION
[
  {
    "name": "${local.container_name}",
    "image": "${var.container_image}",
    "memory": 512,
    "cpu": 256,
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${var.container_port},
        "hostPort": ${var.container_port}
      }
    ]
  }
]
DEFINITION
}

# ECS Service
resource "aws_ecs_service" "my_ecs_service" {
  name            = local.service_name
  cluster         = aws_ecs_cluster.my_ecs_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = true
  }
}

# Security Group for ECS Service
resource "aws_security_group" "ecs_service_sg" {
  vpc_id = data.aws_vpc.existing_vpc.id

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
