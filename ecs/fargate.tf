
provider "aws" {

  region  = "ap-south-1"
  profile = "colearn"
}

resource "aws_iam_role" "fargate" {
  name = "fargate-role"
  path = "/serviceaccounts/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = [
            "ecs.amazonaws.com",
            "ecs-tasks.amazonaws.com"
          ]
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "fargate" {
  name = "fargate-execution-role"
  role = aws_iam_role.fargate.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:CompleteLayerUpload",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetLifecyclePolicy"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_ecs_cluster" "cluster" {
  name = "weby-cluster"
}

resource "aws_ecs_task_definition" "task" {
  family = "service"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = aws_iam_role.fargate.arn
  network_mode       = "awsvpc"
  cpu                = 256
  memory             = 512
  container_definitions = jsonencode([
    {
      name      = "weby_ufg"
      image     = "407333443342.dkr.ecr.ap-south-1.amazonaws.com/weby:main"
      essential = true
      portMappings = [
      {
        containerPort = 3000
        hostPort      = 3000
      },
        {
            containerPort = 80
            hostPort      = 80
          }
      ]
    }
  ])
}
##

resource "aws_ecs_service" "service" {
  name            = "service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1

  network_configuration {
    subnets          = ["subnet-0a6e7b8ea951db6fa"]
    assign_public_ip = true
  }

//  load_balancer {
//    target_group_arn = aws_lb_target_group.group.arn
//    container_name   = "weby_ufg"
//    container_port   = 3000
//  }
  deployment_controller {
    type = "ECS"
  }
  ##
  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE"
    weight            = 100
  }
}

