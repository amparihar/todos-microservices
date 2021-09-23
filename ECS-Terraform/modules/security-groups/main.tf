
locals {
  vpcid = var.vpcid
}
resource "aws_security_group" "ecs_load_balanced_frontend_microservices" {
  name   = "${var.app_name}-sg-ecs-load-balanced-frontend-microservices-${var.stage_name}"
  vpc_id = local.vpcid

  ingress {
    from_port       = var.container_ports["front_end_microservice"]
    to_port         = var.container_ports["front_end_microservice"]
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "sg-ecs-load-balanced-frontend-microservices-${var.app_name}"
    Stage = var.stage_name
  }
}

resource "aws_security_group" "ecs_load_balanced_backend_microservices" {
  name   = "${var.app_name}-sg-ecs-load-balanced-backend-microservices-${var.stage_name}"
  vpc_id = local.vpcid

  ingress {
    from_port       = var.container_ports["user_microservice"]
    to_port         = var.container_ports["user_microservice"]
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }
  ingress {
    from_port       = var.container_ports["group_microservice"]
    to_port         = var.container_ports["group_microservice"]
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }
  ingress {
    from_port       = var.container_ports["task_microservice"]
    to_port         = var.container_ports["task_microservice"]
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "sg-ecs-load-balanced-backend-microservices-${var.app_name}"
    Stage = var.stage_name
  }
}

resource "aws_security_group" "ecs_progress_tracker_microservice" {
  name   = "${var.app_name}-sg-ecs-progress-tracker-microservices-${var.stage_name}"
  vpc_id = local.vpcid

  ingress {
    from_port       = var.container_ports["progress_tracker_microservice"]
    to_port         = var.container_ports["progress_tracker_microservice"]
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_load_balanced_backend_microservices.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "sg-ecs-ecs_progress-tracker-microservices-${var.app_name}"
    Stage = var.stage_name
  }
}

resource "aws_security_group" "ecs_mysql_db_microservice" {
  name   = "${var.app_name}-sg-ecs-mysql-db-microservices-${var.stage_name}"
  vpc_id = local.vpcid

  ingress {
    from_port = var.container_ports["mysql_db_microservice"]
    to_port   = var.container_ports["mysql_db_microservice"]
    protocol  = "tcp"
    security_groups = [
      aws_security_group.ecs_load_balanced_backend_microservices.id,
      aws_security_group.ecs_progress_tracker_microservice.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "sg-ecs-ecs-mysql-db-microservice-${var.app_name}"
    Stage = var.stage_name
  }
}

# EC2 Instance security Group
resource "aws_security_group" "ec2_instance" {
  name   = "${var.app_name}-sg-ec2-instance-${var.stage_name}"
  vpc_id = var.vpcid

  ingress {
    protocol        = "tcp"
    from_port       = var.container_ports["progress_tracker_microservice"]
    to_port         = var.container_ports["progress_tracker_microservice"]
    security_groups = [aws_security_group.ecs_load_balanced_backend_microservices.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "security_group_ids" {
  value = {
    ecs_load_balanced_frontend_microservices = aws_security_group.ecs_load_balanced_frontend_microservices.id
    ecs_load_balanced_backend_microservices  = aws_security_group.ecs_load_balanced_backend_microservices.id
    ecs_progress_tracker_microservice        = aws_security_group.ecs_progress_tracker_microservice.id
    ecs_mysql_db_microservice                = aws_security_group.ecs_mysql_db_microservice.id
    ec2_instance                             = aws_security_group.ec2_instance.id
  }
}