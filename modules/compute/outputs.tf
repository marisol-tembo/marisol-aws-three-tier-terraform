output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.app.name
}

output "launch_template_id" {
  description = "Launch template ID"
  value       = aws_launch_template.app.id
}

output "ec2_role_arn" {
  description = "IAM role ARN for EC2 instances"
  value       = aws_iam_role.ec2.arn
}
