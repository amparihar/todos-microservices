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

resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "user_microservice" {
  family                   = "td-user-microservice-${local.name_suffix}"
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = var.task_memory["user_microservice"]
  cpu                      = var.task_cpu["user_microservice"]

  # For task definitions that use the awsvpc network mode, you should only specify the containerPort. 
  # The hostPort can be left blank or it must be the same value as the containerPort
  container_definitions = jsonencode(
    [
      {
        "image" = "785548451685.dkr.ecr.ap-south-1.amazonaws.com/todos:user-microsvc"
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
            "value" = var.mysqldb_service_name
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
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = var.task_memory["group_microservice"]
  cpu                      = var.task_cpu["group_microservice"]

  container_definitions = jsonencode(
    [
      {
        "image" = "785548451685.dkr.ecr.ap-south-1.amazonaws.com/todos:group-microsvc"
        "name"  = "group-microservice-${local.name_suffix}"
        "portMappings" = [
          {
            "containerPort" = var.container_ports["group_microservice"]
          }
        ]
        "environment" = [
          {
            name  = "RDS_HOST"
            value = var.mysqldb_service_name
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

resource "aws_ecs_task_definition" "task_microservice" {
  family                   = "td-task-microservice-${local.name_suffix}"
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = var.task_memory["task_microservice"]
  cpu                      = var.task_cpu["task_microservice"]

  container_definitions = jsonencode(
    [
      {
        "image" = "785548451685.dkr.ecr.ap-south-1.amazonaws.com/todos:task-microsvc"
        "name"  = "task-microservice-${local.name_suffix}"
        "portMappings" = [
          {
            "containerPort" = var.container_ports["task_microservice"]
          }
        ]
        "environment" = [
          {
            name  = "RDS_HOST"
            value = var.mysqldb_service_name
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

resource "aws_ecs_task_definition" "mysql_db_microservice" {
  family                   = "td-mysql-db-microservice-${local.name_suffix}"
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = var.task_memory["mysql_db_microservice"]
  cpu                      = var.task_cpu["mysql_db_microservice"]

  container_definitions = jsonencode(
    [
      {
        "image" = "785548451685.dkr.ecr.ap-south-1.amazonaws.com/todos:mysql-db-microsvc"
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
            value = var.mysqldb_service_name
          }
        ]
      }
  ])
}

resource "aws_ecs_task_definition" "front_end_microservice" {
  family                   = "td-front-end-microservice-${local.name_suffix}"
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = var.task_memory["front_end_microservice"]
  cpu                      = var.task_cpu["front_end_microservice"]

  container_definitions = jsonencode(
    [
      {
        "image" = "785548451685.dkr.ecr.ap-south-1.amazonaws.com/todos:mytodos-microsvc"
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

resource "aws_security_group" "ecs_load_balanced_frontend_microservices" {
  name   = "${var.app_name}-sg-ecs-load-balanced-frontend-microservices-${var.stage_name}"
  vpc_id = var.vpcid

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
  vpc_id = var.vpcid

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
  
  # ingress {
  #   from_port       = 80
  #   to_port         = 80
  #   protocol        = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

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

resource "aws_security_group" "ecs_mysql_db_microservices" {
  name   = "${var.app_name}-sg-ecs-mysql-db-microservices-${var.stage_name}"
  vpc_id = var.vpcid

  ingress {
    from_port       = var.container_ports["mysql_db_microservice"]
    to_port         = var.container_ports["mysql_db_microservice"]
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
    Name  = "sg-ecs-ecs_mysql_db_microservices-${var.app_name}"
    Stage = var.stage_name
  }
}

resource "aws_ecs_service" "user_microservice" {
  name                              = "user-ecs-svc-${local.name_suffix}"
  cluster                           = aws_ecs_cluster.main.id
  task_definition                   = aws_ecs_task_definition.user_microservice.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  scheduling_strategy               = "REPLICA"
  health_check_grace_period_seconds = 147

  network_configuration {
    assign_public_ip = true
    subnets          = var.subnets
    security_groups  = [aws_security_group.ecs_load_balanced_backend_microservices.id]
  }

  load_balancer {
    container_name   = "user-microservice-${local.name_suffix}"
    container_port   = var.container_ports["user_microservice"]
    target_group_arn = var.target_groups["user_microservice"]
  }
}

resource "aws_ecs_service" "group_microservice" {
  name                              = "group-ecs-svc-${local.name_suffix}"
  cluster                           = aws_ecs_cluster.main.id
  task_definition                   = aws_ecs_task_definition.group_microservice.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  scheduling_strategy               = "REPLICA"
  health_check_grace_period_seconds = 147

  network_configuration {
    assign_public_ip = true
    subnets          = var.subnets
    security_groups  = [aws_security_group.ecs_load_balanced_backend_microservices.id]
  }

  load_balancer {
    container_name   = "group-microservice-${local.name_suffix}"
    container_port   = var.container_ports["group_microservice"]
    target_group_arn = var.target_groups["group_microservice"]
  }
}

resource "aws_ecs_service" "task_microservice" {
  name                              = "task-ecs-svc-${local.name_suffix}"
  cluster                           = aws_ecs_cluster.main.id
  task_definition                   = aws_ecs_task_definition.task_microservice.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  scheduling_strategy               = "REPLICA"
  health_check_grace_period_seconds = 147

  network_configuration {
    assign_public_ip = true
    subnets          = var.subnets
    security_groups  = [aws_security_group.ecs_load_balanced_backend_microservices.id]
  }

  load_balancer {
    container_name   = "task-microservice-${local.name_suffix}"
    container_port   = var.container_ports["task_microservice"]
    target_group_arn = var.target_groups["task_microservice"]
  }
}

resource "aws_ecs_service" "mysql_db_microservice" {
  name                              = "mysql-db-ecs-svc-${local.name_suffix}"
  cluster                           = aws_ecs_cluster.main.id
  task_definition                   = aws_ecs_task_definition.mysql_db_microservice.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  scheduling_strategy               = "REPLICA"
  
  # Health check grace period is only valid for services configured to use load balancers

  network_configuration {
    assign_public_ip = true
    subnets          = var.subnets
    security_groups  = [aws_security_group.ecs_mysql_db_microservices.id]
  }

  # service discovery
  service_registries {
    registry_arn = var.mysqldb_registry_arn
  }
}

resource "aws_ecs_service" "front_end_microservice" {
  name                              = "front-end-ecs-svc-${local.name_suffix}"
  cluster                           = aws_ecs_cluster.main.id
  task_definition                   = aws_ecs_task_definition.front_end_microservice.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  scheduling_strategy               = "REPLICA"
  health_check_grace_period_seconds = 147

  network_configuration {
    assign_public_ip = true
    subnets          = var.subnets
    security_groups  = [aws_security_group.ecs_load_balanced_frontend_microservices.id]
  }

  load_balancer {
    container_name   = "front-end-microservice-${local.name_suffix}"
    container_port   = var.container_ports["front_end_microservice"]
    target_group_arn = var.target_groups["front_end_microservice"]
  }
}