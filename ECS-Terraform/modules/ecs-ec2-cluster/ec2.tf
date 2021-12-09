resource "aws_ecs_cluster" "ec2" {
  name = var.ecs_ec2_cluster_name
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  role = var.ecs_ec2_instance_role_name
}

# auto scaling group
resource "aws_autoscaling_group" "ecs_ec2_asg" {
  name                 = "ecs-ec2-asg-${local.name_suffix}"
  vpc_zone_identifier  = var.subnets
  min_size             = var.min_instances    # default 1
  max_size             = var.max_instances    # default 3
  desired_capacity     = var.desired_capacity # default 1
  launch_configuration = aws_launch_configuration.ecs_ec2_lc[0].name
  # launch_template {
  #   name    = aws_launch_template.ecs_ec2_lt[0].name
  #   version = "$Latest"
  # }
  health_check_type         = "EC2"
  health_check_grace_period = 120
  default_cooldown          = 30
  termination_policies      = ["OldestInstance"]

  tag {
    key                 = "Name"
    value               = "${var.app_name}-${var.stage_name}-${var.ecs_ec2_cluster_name}"
    propagate_at_launch = true
  }
  depends_on = [
    aws_launch_configuration.ecs_ec2_lc
  ]
}

# launch configuration
resource "aws_launch_configuration" "ecs_ec2_lc" {
  count                       = 1
  name_prefix                 = "ecs-ec2-lc-${local.name_suffix}"
  security_groups             = [var.security_group_ids["ec2_instance"]]
  image_id                    = data.aws_ami.latest_ecs_ami.id
  instance_type               = var.instance_type # default t2.medium
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  user_data                   = data.template_file.ecs_ec2_instance_user_data.rendered
  associate_public_ip_address = var.assign_public_ip
}

# launch template
resource "aws_launch_template" "ecs_ec2_lt" {
  count = 0
  name  = "ecs-ec2-lt-${local.name_suffix}"
  #vpc_security_group_ids = [var.security_group_ids["ec2_instance"]]
  image_id      = data.aws_ami.latest_ecs_ami.id
  instance_type = var.instance_type # default t2.small
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }
  user_data = data.template_file.ecs_ec2_instance_user_data.rendered

  network_interfaces {
    associate_public_ip_address = var.assign_public_ip
    security_groups             = [var.security_group_ids["ec2_instance"]]
  }
}

# Task Defs
resource "aws_ecs_task_definition" "progress_tracker_microservice" {
  family                   = "td-progress-tracker-microservice-${local.name_suffix}"
  execution_role_arn       = var.ecs_task_execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  memory                   = "512"

  container_definitions = jsonencode(
    [
      {
        "image" = var.container_images["progress_tracker_microservice"]
        "name"  = "progress-tracker-microservice-${local.name_suffix}"
        "portMappings" = [
          {
            "containerPort" = var.container_ports["progress_tracker_microservice"]
            "hostPort"      = var.container_ports["progress_tracker_microservice"]
          }
        ]

        "environment" = [
          {
            name  = "RDS_HOST"
            value = var.mysqldb_discovery_service_name
          },
          {
            name  = "RDS_PORT"
            value = tostring("${var.container_ports["mysql_db_microservice"]}")
          },
          {
            name  = "RDS_DB_NAME"
            value = "todosdb"
          },
          {
            name  = "RDS_USERNAME"
            value = "admin"
          },
          {
            name  = "RDS_PASSWORD"
            value = "Password123"
          },
          {
            name  = "RDS_CONN_POOL_SIZE"
            value = "2"
          },
          {
            name  = "JWT_ACCESS_TOKEN"
            value = var.jwt_access_token
          }
        ]
      }
  ])
}

resource "aws_ecs_service" "progress_tracker_microservice" {
  name                = "progress-tracker-ecs-svc-${local.name_suffix}"
  cluster             = aws_ecs_cluster.ec2.id
  task_definition     = aws_ecs_task_definition.progress_tracker_microservice.arn
  desired_count       = 2
  launch_type         = "EC2"     # defaults to EC2
  scheduling_strategy = "REPLICA" # defaults to REPLICA

  # Task placement strategy distributes tasks evenly across Availability Zones 
  # and then bin packs tasks based on memory within each Availability Zone.
  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }
  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }

  # required only for 'awsvpc' network
  network_configuration {
    subnets         = var.subnets
    security_groups = [var.security_group_ids["ecs_progress_tracker_microservice"]]
  }

  # service discovery
  service_registries {
    registry_arn = var.progress_tracker_discovery_service_registry_arn
    #container_name and container_port required for 'host' & 'bridge' network
    #container_name = "progress-tracker-microservice-${local.name_suffix}"
    #container_port = var.container_ports["progress_tracker_microservice"]
  }
}