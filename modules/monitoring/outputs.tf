output "alarm_names" {
  description = "Names of created CloudWatch alarms"
  value = [
    aws_cloudwatch_metric_alarm.unhealthy_hosts.alarm_name,
    aws_cloudwatch_metric_alarm.asg_cpu_high.alarm_name,
    aws_cloudwatch_metric_alarm.rds_cpu_high.alarm_name,
  ]
}
