
resource "aws_iam_role" "codebuild_service_role" {
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.code_build_assume_role_policy.json
}

resource "aws_iam_policy" "codebuild_service_role_policy" {
  path   = "/" # Path in which to create the policy
  policy = data.aws_iam_policy_document.code_build_role_iam_policy.json
}

resource "aws_iam_role_policy_attachment" "codebuild_service_role_policy" {
  role       = aws_iam_role.codebuild_service_role.name
  policy_arn = aws_iam_policy.codebuild_service_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryPowerUser" {
  role       = aws_iam_role.codebuild_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# --------------------------------------------------------------
# Code Build Project - Frontend
# --------------------------------------------------------------
resource "aws_codebuild_project" "frontend_microservice" {
  name        = "frontend-microservice-${local.name_suffix}"
  description = "Docker build for the frontend microservice"

  build_timeout = "30" # default is 60 minutes
  service_role  = aws_iam_role.codebuild_service_role.arn

  # customer master key (CMK) to be used for encrypting the build output artifacts
  # encryption_key = var.create_cmk ? aws_kms_alias.artifacts[0].arn : ""

  # output artifact type
  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_MEDIUM"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    # default type is PLAINTEXT
    environment_variable {
      name  = "ECR_REPOSITORY_NAME"
      value = aws_ecr_repository.frontend_microservice.name
    }
    environment_variable {
      name  = "ECS_CONTAINER_NAME"
      value = "front-end-microservice-${local.name_suffix}"
    }
    environment_variable {
      name  = "ECS_CONTAINER_PORT"
      value = var.container_ports["front_end_microservice"]
    }
  }

  source {
    type = "CODEPIPELINE"
    #buildspec = "buildspec.yml"
  }
}
