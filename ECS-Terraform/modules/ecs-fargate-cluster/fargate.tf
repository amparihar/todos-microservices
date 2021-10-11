resource "aws_ecs_cluster" "fargate" {
  name = var.ecs_fargate_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# ECS Task Defs
resource "aws_ecs_task_definition" "user_microservice" {
  family                   = "td-user-microservice-${local.name_suffix}"
  task_role_arn            = var.ecs_task_role_arn
  execution_role_arn       = var.ecs_task_execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = var.task_memory["user_microservice"]
  cpu                      = var.task_cpu["user_microservice"]

  # For task definitions that use the awsvpc network mode, you should only specify the containerPort. 
  # The hostPort can be left blank or it must be the same value as the containerPort
  container_definitions = jsonencode(
    [
      {
        "image" = var.container_images["user_microservice"]
        "name"  = "user-microservice-${local.name_suffix}"
        "portMappings" = [
          {
            "protocol"      = "tcp"
            "containerPort" = var.container_ports["user_microservice"]
          }
        ]
        "environment" = [
          {
            "name"  = "RDS_HOST"
            "value" = var.mysqldb_discovery_service_name
          },
          {
            "name"  = "RDS_PORT"
            "value" = tostring("${var.container_ports["mysql_db_microservice"]}")
          },
          {
            "name"  = "RDS_DB_NAME"
            "value" = "todosdb"
          },
          {
            "name"  = "RDS_USERNAME"
            "value" = "admin"
          },
          {
            "name"  = "RDS_PASSWORD"
            "value" = "Password123"
          },
          {
            "name"  = "RDS_CONN_POOL_SIZE"
            "value" = "2"
          },
          {
            "name"  = "JWT_ACCESS_TOKEN"
            "value" = var.jwt_access_token
          }
        ]
      }
  ])
}

resource "aws_ecs_task_definition" "group_microservice" {
  family                   = "td-group-microservice-${local.name_suffix}"
  task_role_arn            = var.ecs_task_role_arn
  execution_role_arn       = var.ecs_task_execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = var.task_memory["group_microservice"]
  cpu                      = var.task_cpu["group_microservice"]

  container_definitions = jsonencode(
    [
      {
        "image" = var.container_images["group_microservice"]
        "name"  = "group-microservice-${local.name_suffix}"
        "portMappings" = [
          {
            "containerPort" = var.container_ports["group_microservice"]
          }
        ]
        "logConfiguration" = {
          logDriver = "awslogs"
          options = {
            awslogs-create-group  = "true"
            awslogs-region        = var.regionid
            awslogs-group         = "/ecs/${var.ecs_fargate_cluster_name}/group-microservice"
            awslogs-stream-prefix = "ecs"
          }
        }
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
          },
          {
            name  = "PROGRESS_TRACKER_API_HOST"
            value = var.progress_tracker_discovery_service_name
          },
          {
            name  = "PROGRESS_TRACKER_API_PORT"
            value = tostring(var.container_ports["progress_tracker_microservice"])
          }
        ]
      }
  ])
}

resource "aws_ecs_task_definition" "task_microservice" {
  family                   = "td-task-microservice-${local.name_suffix}"
  task_role_arn            = var.ecs_task_role_arn
  execution_role_arn       = var.ecs_task_execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = var.task_memory["task_microservice"]
  cpu                      = var.task_cpu["task_microservice"]

  container_definitions = jsonencode(
    [
      {
        "image" = var.container_images["task_microservice"]
        "name"  = "task-microservice-${local.name_suffix}"
        "portMappings" = [
          {
            "containerPort" = var.container_ports["task_microservice"]
          }
        ]
        # "logConfiguration" = {
        #   logDriver = "awslogs"
        #   options = {
        #     awslogs-create-group  = "true"
        #     awslogs-region        = var.regionid
        #     awslogs-group         = "/ecs/${var.ecs_fargate_cluster_name}/task-microservice"
        #     awslogs-stream-prefix = "ecs"
        #   }
        # }
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
          },
          {
            name  = "PROGRESS_TRACKER_API_HOST"
            value = var.progress_tracker_discovery_service_name
          },
          {
            name  = "PROGRESS_TRACKER_API_PORT"
            value = tostring(var.container_ports["progress_tracker_microservice"])
          }
        ]
      }
  ])
}

# Progress Tracker microservice task def
# resource "aws_ecs_task_definition" "progress_tracker_microservice" {
#   family                   = "td-progress-tracker-microservice-${local.name_suffix}"
#   task_role_arn            = var.ecs_task_role_arn
#   execution_role_arn       = var.ecs_task_execution_role_arn
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   memory                   = var.task_memory["progress_tracker_microservice"]
#   cpu                      = var.task_cpu["progress_tracker_microservice"]

#   container_definitions = jsonencode(
#     [
#       {
#         "image" = var.container_images["progress_tracker_microservice"]
#         "name"  = "progress-tracker-microservice-${local.name_suffix}"
#         "portMappings" = [
#           {
#             "containerPort" = var.container_ports["progress_tracker_microservice"]
#             "hostPort"      = var.container_ports["progress_tracker_microservice"]
#           }
#         ]
#         # "logConfiguration" = {
#         #   logDriver = "awslogs"
#         #   options = {
#         #     awslogs-create-group  = "true"
#         #     awslogs-region        = var.regionid
#         #     awslogs-group         = "/ecs/${var.ecs_fargate_cluster_name}/progress-tracker-microservice"
#         #     awslogs-stream-prefix = "ecs"
#         #   }
#         # }
#         "environment" = [
#           {
#             name  = "RDS_HOST"
#             value = var.mysqldb_discovery_service_name
#           },
#           {
#             name  = "RDS_PORT"
#             value = tostring("${var.container_ports["mysql_db_microservice"]}")
#           },
#           {
#             name  = "RDS_DB_NAME"
#             value = "todosdb"
#           },
#           {
#             name  = "RDS_USERNAME"
#             value = "admin"
#           },
#           {
#             name  = "RDS_PASSWORD"
#             value = "Password123"
#           },
#           {
#             name  = "RDS_CONN_POOL_SIZE"
#             value = "2"
#           },
#           {
#             name  = "JWT_ACCESS_TOKEN"
#             value = var.jwt_access_token
#           }
#         ]
#       }
#   ])
# }
resource "aws_ecs_task_definition" "mysql_db_microservice" {
  family                   = "td-mysql-db-microservice-${local.name_suffix}"
  task_role_arn            = var.ecs_task_role_arn
  execution_role_arn       = var.ecs_task_execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = var.task_memory["mysql_db_microservice"]
  cpu                      = var.task_cpu["mysql_db_microservice"]

  container_definitions = jsonencode(
    [
      {
        "image" = var.container_images["mysql_db_microservice"]
        "name"  = "mysql-db-microservice-${local.name_suffix}"
        "portMappings" = [
          {
            "containerPort" = var.container_ports["mysql_db_microservice"]
          }
        ]
        "environment" = [
          {
            name  = "MYSQL_ROOT_PASSWORD"
            value = "Password123"
          },
          {
            name  = "MYSQL_DATABASE"
            value = "todosdb"
          },
          {
            name  = "MYSQL_USER"
            value = "admin"
          },
          {
            name  = "MYSQL_PASSWORD"
            value = "Password123"
          },
          {
            name  = "DATABASE_HOST"
            value = var.mysqldb_discovery_service_name
          }
        ]
      }
  ])
}

resource "aws_ecs_task_definition" "front_end_microservice" {
  family                   = "td-front-end-microservice-${local.name_suffix}"
  task_role_arn            = var.ecs_task_role_arn
  execution_role_arn       = var.ecs_task_execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = var.task_memory["front_end_microservice"]
  cpu                      = var.task_cpu["front_end_microservice"]

  container_definitions = jsonencode(
    [
      {
        "image" = var.container_images["front_end_microservice"]
        "name"  = "front-end-microservice-${local.name_suffix}"
        "portMappings" = [
          {
            "containerPort" = var.container_ports["front_end_microservice"]
          }
        ]
        "environment" = [
          {
            name  = "USER_API_BASE_URL"
            value = "http://${var.alb_dns_name}/api"
          },
          {
            name  = "GROUP_API_BASE_URL"
            value = "http://${var.alb_dns_name}/api"
          },
          {
            name  = "TASK_API_BASE_URL"
            value = "http://${var.alb_dns_name}/api"
          }
        ]
      }
  ])
}

# ECS Services
resource "aws_ecs_service" "user_microservice" {
  name                              = "user-ecs-svc-${local.name_suffix}"
  cluster                           = aws_ecs_cluster.fargate.id
  task_definition                   = aws_ecs_task_definition.user_microservice.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  scheduling_strategy               = "REPLICA"
  health_check_grace_period_seconds = 147

  network_configuration {
    assign_public_ip = true
    subnets          = var.subnets
    security_groups  = [var.security_group_ids["ecs_load_balanced_backend_microservices"]]
  }

  load_balancer {
    container_name   = "user-microservice-${local.name_suffix}"
    container_port   = var.container_ports["user_microservice"]
    target_group_arn = var.target_groups["user_microservice"]
  }
}

resource "aws_ecs_service" "group_microservice" {
  name                              = "group-ecs-svc-${local.name_suffix}"
  cluster                           = aws_ecs_cluster.fargate.id
  task_definition                   = aws_ecs_task_definition.group_microservice.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  scheduling_strategy               = "REPLICA"
  health_check_grace_period_seconds = 147

  network_configuration {
    assign_public_ip = true
    subnets          = var.subnets
    security_groups  = [var.security_group_ids["ecs_load_balanced_backend_microservices"]]
  }

  load_balancer {
    container_name   = "group-microservice-${local.name_suffix}"
    container_port   = var.container_ports["group_microservice"]
    target_group_arn = var.target_groups["group_microservice"]
  }
}

resource "aws_ecs_service" "task_microservice" {
  name                              = "task-ecs-svc-${local.name_suffix}"
  cluster                           = aws_ecs_cluster.fargate.id
  task_definition                   = aws_ecs_task_definition.task_microservice.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  scheduling_strategy               = "REPLICA"
  health_check_grace_period_seconds = 147

  network_configuration {
    assign_public_ip = true
    subnets          = var.subnets
    security_groups  = [var.security_group_ids["ecs_load_balanced_backend_microservices"]]
  }

  load_balancer {
    container_name   = "task-microservice-${local.name_suffix}"
    container_port   = var.container_ports["task_microservice"]
    target_group_arn = var.target_groups["task_microservice"]
  }
}

# resource "aws_ecs_service" "progress_tracker_microservice" {
#   name                = "progress-tracker-ecs-svc-${local.name_suffix}"
#   cluster             = aws_ecs_cluster.fargate.id
#   task_definition     = aws_ecs_task_definition.progress_tracker_microservice.arn
#   desired_count       = 2
#   launch_type         = "FARGATE" # defaults to EC2
#   scheduling_strategy = "REPLICA" # defaults to REPLICA
#   # Health check grace period is only valid for services configured to use load balancers

#   network_configuration {
#     assign_public_ip = true
#     subnets          = var.subnets
#     security_groups  = [var.security_group_ids["ecs_progress_tracker_microservice"]]
#   }

#   # service discovery
#   service_registries {
#     registry_arn = var.progress_tracker_discovery_service_registry_arn
#   }
# }

resource "aws_ecs_service" "mysql_db_microservice" {
  name                = "mysql-db-ecs-svc-${local.name_suffix}"
  cluster             = aws_ecs_cluster.fargate.id
  task_definition     = aws_ecs_task_definition.mysql_db_microservice.arn
  desired_count       = 1
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"

  # Health check grace period is only valid for services configured to use load balancers

  network_configuration {
    assign_public_ip = true
    subnets          = var.subnets
    security_groups  = [var.security_group_ids["ecs_mysql_db_microservice"]]
  }

  # service discovery
  service_registries {
    registry_arn = var.mysqldb_discovery_service_registry_arn
  }
}

resource "aws_ecs_service" "front_end_microservice" {
  name                              = "front-end-ecs-svc-${local.name_suffix}"
  cluster                           = aws_ecs_cluster.fargate.id
  task_definition                   = aws_ecs_task_definition.front_end_microservice.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  scheduling_strategy               = "REPLICA"
  health_check_grace_period_seconds = 147

  # rolling update configuration
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 150

  network_configuration {
    assign_public_ip = true
    subnets          = var.subnets
    security_groups  = [var.security_group_ids["ecs_load_balanced_frontend_microservices"]]
  }

  load_balancer {
    container_name   = "front-end-microservice-${local.name_suffix}"
    container_port   = var.container_ports["front_end_microservice"]
    target_group_arn = var.target_groups["front_end_microservice"]
  }

  deployment_controller {
    type = var.enable_blue_green_deployment ? "CODE_DEPLOY" : "ECS"
  }
}

output "service_names" {
  value = {
    "frontend_microservice" = aws_ecs_service.front_end_microservice.name
  }
}
