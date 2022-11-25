data "template_file" "container_definitions" {
  template = file("${var.container_defenitions_path[0]}")
  vars = {

    image              = var.backend_container_config.image
    cpu                = var.backend_container_config.cpu
    memory             = var.backend_container_config.memory
    name               = var.backend_container_config.name
    containerPort      = var.backend_container_config.containerPort
    hostPort           = var.backend_container_config.hostPort
    aws_region         = var.aws_region
    logs_group         = aws_cloudwatch_log_group.log-group.id
    logs_stream_prefix = "${var.ecs_cluster_name}"

  }

}

resource "aws_ecs_task_definition" "hello_world" {
  family                   = "hello-world-app"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = data.template_file.container_definitions.rendered
}

resource "aws_ecs_cluster" "main" {
  name = "${var.ecs_cluster_name}-cluster"
}

resource "aws_ecs_service" "hello_world" {
  name            = "hello-world-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.hello_world.arn
  #iam_role        = aws_iam_role.ServiceRoleForECS.arn

  desired_count = 2

  launch_type = "EC2"

  load_balancer {
    target_group_arn = aws_alb_target_group.default-target-group.arn
    container_name   = "mynginx-quickstart"
    container_port   = 80
  }

  depends_on = [aws_alb_listener.ecs-alb-http-listener]

  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [desired_count]
  }

}
