resource "aws_cloudwatch_log_group" "log-group" {
  name              = "${var.ecs_cluster_name}-logs"
  retention_in_days = var.log_retention_in_days
}

resource "aws_cloudwatch_log_stream" "log-stream" {
  name           = "${var.ecs_cluster_name}-stream"
  log_group_name = aws_cloudwatch_log_group.log-group.name
}
