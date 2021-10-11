resource "aws_ecr_repository" "frontend_microservice" {
  name                 = "frontend-microservice-${local.name_suffix}"
  image_tag_mutability = "IMMUTABLE"
}
