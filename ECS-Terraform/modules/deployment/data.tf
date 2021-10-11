data "aws_caller_identity" "current" {}

# Predefined s3 key
# data "aws_kms_alias" "s3" {
#   name = "alias/aws/s3"
# }

data "aws_iam_policy_document" "artifacts_kms_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "kms:*",
    ]
    resources = [
      "*",
    ]
  }
}

# code build
data "aws_iam_policy_document" "code_build_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "code_build_role_iam_policy" {
  statement {
    sid = "CloudWatchLogsPolicy"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    sid = "CodeCommitPolicy"
    actions = [
      "codecommit:GitPull"
    ]
    resources = ["*"]
  }

  statement {
    sid = "S3GetObjectPolicy"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = ["*"]
  }

  statement {
    sid = "S3PutObjectPolicy"
    actions = [
      "s3:PutObject"
    ]
    resources = ["*"]
  }

  statement {
    sid = "ECRPullPolicy"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = ["*"]
  }

  statement {
    sid = "ECRAuthPolicy"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    sid = "S3BucketIdentity"
    actions = [
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]
    resources = ["*"]
  }

  statement {
    sid = "KMSPolicy"
    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}

#code deploy
data "aws_iam_policy_document" "code_deploy_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

#code pipeline
data "aws_iam_policy_document" "code_pipeline_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "code_pipeline_role_iam_policy" {
  statement {

    actions = [
    "s3:*"]
    resources = [
      aws_s3_bucket.artifacts.arn,
    "${aws_s3_bucket.artifacts.arn}/*"]
  }

  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:Decrypt",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "codecommit:CancelUploadArchive",
      "codecommit:UploadArchive",
      "codecommit:Get*",
      "codecommit:BatchGet*",
      "codecommit:Describe*",
      "codecommit:BatchDescribe*",
      "codecommit:GitPull",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "codedeploy:*",
      "ecs:*",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "iam:PassRole"
    ]
    resources = ["*"]
    condition {
      test     = "StringEqualsIfExists"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }
}
