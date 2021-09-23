output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}
output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}
output "ecs_ec2_instance_role_arn" {
  value = aws_iam_role.ecs_ec2_instance_role.arn
}
output "ecs_ec2_instance_role_name" {
  value = aws_iam_role.ecs_ec2_instance_role.name
}