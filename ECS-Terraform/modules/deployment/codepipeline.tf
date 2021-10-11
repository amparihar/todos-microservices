resource "aws_iam_role" "codepipeline_service_role" {
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.code_pipeline_assume_role_policy.json
}

resource "aws_iam_policy" "codepipeline_service_role_policy" {
  path   = "/" # Path in which to create the policy
  policy = data.aws_iam_policy_document.code_pipeline_role_iam_policy.json
}

resource "aws_iam_role_policy_attachment" "codepipeline_service_role_policy" {
  role       = aws_iam_role.codepipeline_service_role.name
  policy_arn = aws_iam_policy.codepipeline_service_role_policy.arn
}

# --------------------------------------------------------------
# Code Pipeline - Frontend
# --------------------------------------------------------------
resource "aws_codepipeline" "frontend_microservice" {
  name = "frontend_microservice-${local.name_suffix}"

  role_arn = aws_iam_role.codepipeline_service_role.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
    # encryption_key {
    #   id   = aws_kms_alias.artifacts[0].arn
    #   type = "KMS"
    # }
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["frontend-source"]

      configuration = {
        RepositoryName = aws_codecommit_repository.frontend_microservice.repository_name
        BranchName     = "master"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["frontend-source"]
      output_artifacts = ["frontend-build"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.frontend_microservice.name
      }
    }
  }

  # blue/ green deployment
  stage {
    name = "Deploy"
    action {
      name            = "DeployToECS"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["frontend-build"]
      version         = "1"

      configuration = {
        ApplicationName                = aws_codedeploy_app.frontend_microservice.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.frontend_microservice.deployment_group_name
        TaskDefinitionTemplateArtifact = "frontend-build"
        AppSpecTemplateArtifact        = "frontend-build"
        TaskDefinitionTemplatePath     = "taskdef.json"
        AppSpecTemplatePath            = "appspec.json"
        Image1ArtifactName             = "frontend-build"
        Image1ContainerName            = "IMAGE1_NAME"
      }
    }
  }

  # # rolling update
  # stage {
  #   name = "Deploy"
  #   action {
  #     name            = "DeployToECS"
  #     category        = "Deploy"
  #     owner           = "AWS"
  #     provider        = "ECS"
  #     input_artifacts = ["frontend-build"]
  #     version         = "1"

  #     configuration = {
  #       ClusterName       = var.cluster_name
  #       ServiceName       = var.service_names["frontend_microservice"]
  #       FileName          = "imagedefinitions.json"
  #       DeploymentTimeout = "10" # 10 minutes
  #     }
  #   }
  # }
}
