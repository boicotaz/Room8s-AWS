data "template_file" "container_definitions" {
  template = file("${var.container_defenitions_path[0]}")
  vars = {

    image              = var.ecr_repo_url
    aws_region         = var.aws_region
    logs_group         = aws_cloudwatch_log_group.log-group.id
    logs_stream_prefix = "${var.ecs_cluster_name}"
  }

}
resource "aws_ecs_task_definition" "hello_world" {
  family                   = "hello-world-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = data.template_file.container_definitions.rendered
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
