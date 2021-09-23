
data "aws_ami" "latest_ecs_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}


data "template_file" "ecs_ec2_instance_user_data" {
  template = file("${path.module}/templates/user_data.sh")
  #template = base64encode("${path.module}/templates/user_data.sh")

  vars = {
    cluster_name = var.ecs_ec2_cluster_name
    app_name     = var.app_name
    stage_name   = var.stage_name
  }
}
