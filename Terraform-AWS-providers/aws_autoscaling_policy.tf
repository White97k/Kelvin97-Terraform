resource "aws_autoscaling_policy" "CPU_Target_Tracking_Policy" {
  count                     = "${length(var.ASG-NAME)}"
  name                      = "CPU Target Tracking Policy"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = "${var.ASG-NAME[count.index]}"
  estimated_instance_warmup = 180
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}

### ASG-NAME = your auto scaling group name list
