data "template_file" "backend_container_definition" {
  template = file("${var.backend_container_defenition_path[0]}")
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

data "template_file" "frontend_container_definition" {
  template = file("${var.frontend_container_defenition_path[0]}")
  vars = {

    image               = var.frontend_container_config.image
    cpu                 = var.frontend_container_config.cpu
    memory              = var.frontend_container_config.memory
    name                = var.frontend_container_config.name
    containerPort       = var.frontend_container_config.containerPort
    hostPort            = var.frontend_container_config.hostPort
    aws_region          = var.aws_region
    logs_group          = aws_cloudwatch_log_group.log-group.id
    logs_stream_prefix  = "${var.ecs_cluster_name}"
    backend-service-dns = "${aws_service_discovery_service.this.name}.${aws_service_discovery_private_dns_namespace.this.name}"
  }

}

data "template_file" "container_definition" {
  for_each = var.container_config
  template = file("${each.value.templatePath}")
  vars = {
    image               = each.value.image
    cpu                 = each.value.cpu
    memory              = each.value.memory
    name                = each.value.name
    containerPort       = each.value.containerPort
    hostPort            = each.value.hostPort
    backend-service-dns = each.value.enable_service_discovery ? "${aws_service_discovery_service.this.name}.${aws_service_discovery_private_dns_namespace.this.name}" : null

    aws_region         = var.aws_region
    logs_group         = aws_cloudwatch_log_group.log-group.id
    logs_stream_prefix = "${var.ecs_cluster_name}"
  }

}

resource "aws_ecs_task_definition" "frontend_td" {
  family                   = "frontend-app"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = data.template_file.frontend_container_definition.rendered
}

resource "aws_ecs_task_definition" "backend_td" {
  family                   = "backend-app"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = data.template_file.backend_container_definition.rendered
}

resource "aws_ecs_cluster" "main" {
  name = "${var.ecs_cluster_name}-cluster"
}

resource "aws_ecs_service" "frontend" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend_td.arn
  #iam_role        = aws_iam_role.ServiceRoleForECS.arn

  desired_count = 1

  launch_type = "EC2"

  load_balancer {
    target_group_arn = aws_alb_target_group.default-target-group.arn
    container_name   = var.frontend_container_config.name
    container_port   = var.frontend_container_config.containerPort
  }

  depends_on = [aws_alb_listener.ecs-alb-http-listener]

  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [desired_count]
  }

}

resource "aws_ecs_service" "backend" {
  name            = "backend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend_td.arn
  #iam_role        = aws_iam_role.ServiceRoleForECS.arn
  service_registries {
    #registry_arn   = "arn:aws:servicediscovery:us-east-2:425832464758:service/srv-u36cf66rb5wvnnu3"
    registry_arn   = aws_service_discovery_service.this.arn
    container_name = var.backend_container_config.name
    container_port = var.backend_container_config.containerPort
  }

  desired_count = 2

  launch_type = "EC2"

  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [desired_count]
  }

}
