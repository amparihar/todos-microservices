
resource "aws_iam_role" "codedeploy_service_role" {
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.code_deploy_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRoleForECS" {
  role       = aws_iam_role.codedeploy_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

# --------------------------------------------------------------
# Code Deploy application & deployment group - Frontend
# --------------------------------------------------------------
resource "aws_codedeploy_app" "frontend_microservice" {
  compute_platform = "ECS"
  name             = "frontend_microservice-app-${local.name_suffix}"
}

resource "aws_codedeploy_deployment_group" "frontend_microservice" {
  app_name               = aws_codedeploy_app.frontend_microservice.name
  deployment_config_name = var.blue_green_deployment_configurations[var.frontend_microservice_deployment_configuration_name]
  deployment_group_name  = "frontend_microservice-group-${local.name_suffix}"
  service_role_arn       = aws_iam_role.codedeploy_service_role.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    # default is WITHOUT_TRAFFIC_CONTROL
    deployment_option = "WITH_TRAFFIC_CONTROL"
    # default is IN_PLACE
    deployment_type = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.cluster_name
    service_name = var.service_names["frontend_microservice"]
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.listener_arns["blue"]]
      }

      test_traffic_route {
        listener_arns = [var.listener_arns["green"]]
      }

      target_group {
        name = var.target_groups["front_end_microservice"]
      }

      target_group {
        name = var.target_groups["front_end_microservice_green"]
      }
    }
  }
}
