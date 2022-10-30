resource "aws_ecs_task_definition" "hello_world" {
  family                   = "hello-world-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = <<DEFINITION
[
  {
    "image": "425832464758.dkr.ecr.us-east-2.amazonaws.com/quickstart-nginx:latest",
    "cpu": 512,
    "memory": 1024,
    "name": "mynginx-quickstart",
    "networkMode": "awsvpc",
    "logConfiguration": {
      "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
          "awslogs-region": "${var.aws_region}",
          "awslogs-stream-prefix": "${var.ecs_cluster_name}"
        }
      },
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_cluster" "main" {
  name = "example-cluster"
}

resource "aws_ecs_service" "hello_world" {
  name            = "hello-world-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.hello_world.arn
  #iam_role        = aws_iam_role.AWSServiceRoleForECS.arn

  desired_count = 2

  launch_type = "FARGATE"

  network_configuration {
    subnets          = module.vpc.public_subnets
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_service.id]
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.default-target-group.arn
    container_name   = "mynginx-quickstart"
    container_port   = 80
  }

  #depends_on = [aws_alb_listener.ecs-alb-http-listener, aws_iam_role_policy.AWSServiceRoleForECS_policy]
  depends_on = [aws_alb_listener.ecs-alb-http-listener]
}
