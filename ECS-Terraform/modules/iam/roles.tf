# task role
resource "aws_iam_policy" "ecs_task_role_iam_policy" {
  path   = "/" # Path in which to create the policy
  policy = data.aws_iam_policy_document.ecs_task_role_iam_policy.json
}

resource "aws_iam_role" "ecs_task_role" {
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "task_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_role_iam_policy.arn
}

# task execution role
resource "aws_iam_policy" "ecs_task_execution_role_iam_policy" {
  path   = "/" # Path in which to create the policy
  policy = data.aws_iam_policy_document.ecs_task_execution_role_iam_policy.json
}

resource "aws_iam_role" "ecs_task_execution_role" {
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_role_iam_policy.arn
}


# EC2 instance role
resource "aws_iam_role" "ecs_ec2_instance_role" {
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_ec2_instance_role_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_instance_role_policy_attachment" {
  role       = aws_iam_role.ecs_ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# ECS EC2 task autoscaling
resource "aws_iam_role" "ecs_ec2_task_autoscaling_role" {
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_ec2_task_autoscaling_role_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_task_autoscaling_role_policy_attachment" {
  role       = aws_iam_role.ecs_ec2_task_autoscaling_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}
