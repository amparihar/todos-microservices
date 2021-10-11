
# --------------------------------------------------------------
# Code Commit Repository - Frontend
# --------------------------------------------------------------
resource "aws_codecommit_repository" "frontend_microservice" {
  repository_name = "frontend-microservice-${local.name_suffix}"
  description     = "frontend microservice code repository"
}
