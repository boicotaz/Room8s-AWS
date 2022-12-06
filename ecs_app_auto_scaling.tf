resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 5
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.this["backend"].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

#### Scale in
resource "aws_appautoscaling_policy" "ecs_policy_slace_in" {
  name               = "ecs-policy-scale-in"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      #metric_interval_lower_bound = 0 
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "scale_in_alarm" {
  alarm_name          = "scalin-in-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  datapoints_to_alarm = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "40"
  unit                = "Percent"
  dimensions = {
    ServiceName = "${aws_ecs_service.this["backend"].name}"
    ClusterName = "${aws_ecs_cluster.main.name}"
  }

  alarm_description = "Alarm scale in policy, when CPU Usage below 40%"
  alarm_actions     = [aws_appautoscaling_policy.ecs_policy_slace_in.arn]
}
#### 

#### Scale out
resource "aws_appautoscaling_policy" "ecs_policy_slace_out" {
  name               = "ecs-policy-scale-out"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "scale_out_alarm" {
  alarm_name          = "scalin-out-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "60"
  unit                = "Percent"

  dimensions = {
    ServiceName = "${aws_ecs_service.this["backend"].name}"
    ClusterName = "${aws_ecs_cluster.main.name}"
  }

  alarm_description = "Alarm scale out policy, when CPU Usage Above 60%"
  alarm_actions     = [aws_appautoscaling_policy.ecs_policy_slace_out.arn]
}
