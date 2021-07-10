provider "aws" {
  region = var.aws_regions[var.aws_region]
}

# --------------------------------------------------------------
# VPC
# --------------------------------------------------------------
module "vpc" {
  source     = "./modules/vpc"
  app_name   = var.app_name
  stage_name = var.stage_name
}

output "vpcid" {
  value = [module.vpc.vpcid]
}

# --------------------------------------------------------------
# ALB
# --------------------------------------------------------------

module "alb" {
  source     = "./modules/load-balancer"
  app_name   = var.app_name
  stage_name = var.stage_name
  vpcid      = module.vpc.vpcid
  subnets    = module.vpc.public_subnet_ids
}

output "alb_arn" {
  value = module.alb.arn
}

output "alb_dns_name" {
  value = module.alb.dns_name
}

# --------------------------------------------------------------
# Service Discovery
# --------------------------------------------------------------

module "servicediscovery" {
  source     = "./modules/service-discovery"
  app_name   = var.app_name
  stage_name = var.stage_name
  vpcid      = module.vpc.vpcid
}

output "mysqldb_service_name" {
  value = module.servicediscovery.mysqldb_service_name
}

output "mysqldb_registry_arn" {
  value = module.servicediscovery.mysqldb_registry_arn
}

# --------------------------------------------------------------
# ECS Fargate
# --------------------------------------------------------------
module "ecs" {
  source                = "./modules/ecs-cluster"
  app_name              = var.app_name
  stage_name            = var.stage_name
  ecs_cluster_name      = var.ecs_cluster_name
  vpcid                 = module.vpc.vpcid
  subnets               = module.vpc.public_subnet_ids
  alb_security_group_id = module.alb.security_group_id
  alb_dns_name          = module.alb.dns_name[0]
  target_groups = {
    "user_microservice"      = module.alb.user_microservice_target_group_arn
    "group_microservice"     = module.alb.group_microservice_target_group_arn
    "task_microservice"      = module.alb.task_microservice_target_group_arn
    "front_end_microservice" = module.alb.front_end_microservice_target_group_arn
  }
  mysqldb_service_name = module.servicediscovery.mysqldb_service_name
  mysqldb_registry_arn = module.servicediscovery.mysqldb_registry_arn
  jwt_access_token     = var.jwt_access_token
}