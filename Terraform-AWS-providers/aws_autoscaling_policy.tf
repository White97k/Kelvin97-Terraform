resource "aws_autoscaling_policy" "CPU_Target_Tracking_Policy" {
  count                     = "${length(var.app_type)}"
  name                      = "CPU Target Tracking Policy"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = "${var.app_type[count.index]}"
  estimated_instance_warmup = 180
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
