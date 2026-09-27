# -----------------------------
# Scalable target
# -----------------------------
resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = var.ecs_max_capacity
  min_capacity       = var.ecs_min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# -----------------------------
# Target tracking policy 1: CPU utilization
# -----------------------------
resource "aws_appautoscaling_policy" "cpu" {
  name               = "${var.project_name}-cpu-target-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 55.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# -----------------------------
# Target tracking policy 2: ALB request count per target
# -----------------------------
resource "aws_appautoscaling_policy" "request_count" {
  name               = "${var.project_name}-request-count-target-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb.main.arn_suffix}/${aws_lb_target_group.app.arn_suffix}"
    }
    target_value       = 1000.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# -----------------------------
# Scheduled scaling: pre-provision capacity for a known ticket-sale opening
# -----------------------------
resource "aws_appautoscaling_scheduled_action" "scale_out_before_peak" {
  name               = "${var.project_name}-scale-out-ticket-sale"
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension

  # One-off schedule for a known sale opening (adjust the date/time per sale).
  # AWS "at(...)" expressions run exactly once, equivalent to Recurrence: Once
  # in the console.
  schedule = "at(2026-09-23T10:00:00)"
  timezone = "Europe/Amsterdam"

  scalable_target_action {
    min_capacity = 4
    max_capacity = var.ecs_max_capacity
  }
}

resource "aws_appautoscaling_scheduled_action" "scale_in_after_peak" {
  name               = "${var.project_name}-scale-in-after-ticket-sale"
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension

  schedule = "at(2026-09-23T18:00:00)"
  timezone = "Europe/Amsterdam"

  scalable_target_action {
    min_capacity = var.ecs_min_capacity
    max_capacity = var.ecs_max_capacity
  }
}
