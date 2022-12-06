data "template_file" "ecs_container_definition" {
  for_each = var.ecs_container_config
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

resource "aws_ecs_task_definition" "this" {
  for_each                 = var.ecs_task_definition_config
  family                   = "${each.key}-app"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = data.template_file.ecs_container_definition["${each.key}"].rendered
}

resource "aws_ecs_cluster" "main" {
  name = "${var.ecs_cluster_name}-cluster"
}

resource "aws_ecs_service" "this" {
  for_each        = var.ecs_service_config
  name            = "${each.key}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.this[each.key].arn
  #iam_role        = aws_iam_role.ServiceRoleForECS.arn

  desired_count = each.value.desired_count

  launch_type = "EC2"

  dynamic "load_balancer" {
    for_each = each.value.create_loadbalancer ? [1] : []
    content {
      target_group_arn = aws_alb_target_group.default-target-group.arn
      container_name   = var.ecs_container_config["frontend"].name
      container_port   = var.ecs_container_config["frontend"].containerPort
    }
  }
  dynamic "service_registries" {
    for_each = each.value.associate_service_registry ? [1] : []
    content {
      registry_arn   = aws_service_discovery_service.this.arn
      container_name = var.ecs_container_config["backend"].name
      container_port = var.ecs_container_config["backend"].containerPort
    }
  }

  depends_on = [aws_alb_listener.ecs-alb-http-listener]

  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [desired_count]
  }

}
