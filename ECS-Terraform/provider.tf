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

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

# --------------------------------------------------------------
# ALB
# --------------------------------------------------------------

module "alb" {
  source                       = "./modules/load-balancer"
  app_name                     = var.app_name
  stage_name                   = var.stage_name
  vpcid                        = module.vpc.vpcid
  subnets                      = module.vpc.public_subnet_ids
  enable_blue_green_deployment = var.app_enable_blue_green_deployment
}

output "alb_arn" {
  value = module.alb.arn
}

output "alb_dns_name" {
  value = module.alb.dns_name
}

# --------------------------------------------------------------
# Security Groups
# --------------------------------------------------------------

module "sg" {
  source                = "./modules/security-groups"
  app_name              = var.app_name
  stage_name            = var.stage_name
  vpcid                 = module.vpc.vpcid
  container_ports       = var.app_container_ports
  alb_security_group_id = module.alb.security_group_id
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

output "mysqldb_discovery_service_name" {
  value = module.servicediscovery.mysqldb_discovery_service_name
}

output "mysqldb_discovery_service_registry_arn" {
  value = module.servicediscovery.mysqldb_discovery_service_registry_arn
}

output "progress_tracker_discovery_service_name" {
  value = module.servicediscovery.progress_tracker_discovery_service_name
}

output "progress_tracker_discovery_service_registry_arn" {
  value = module.servicediscovery.progress_tracker_discovery_service_registry_arn
}

# --------------------------------------------------------------
# IAM
# --------------------------------------------------------------

module "iam" {
  source = "./modules/iam"
}

# --------------------------------------------------------------
# ECS Fargate
# --------------------------------------------------------------
module "ecs_fargate" {
  source                                          = "./modules/ecs-fargate-cluster"
  app_name                                        = var.app_name
  stage_name                                      = var.stage_name
  ecs_task_role_arn                               = module.iam.ecs_task_role_arn
  ecs_task_execution_role_arn                     = module.iam.ecs_task_execution_role_arn
  regionid                                        = var.aws_regions[var.aws_region]
  ecs_fargate_cluster_name                        = var.ecs_fargate_cluster_name
  security_group_ids                              = module.sg.security_group_ids
  subnets                                         = module.vpc.private_subnet_ids
  alb_dns_name                                    = module.alb.dns_name[0]
  container_ports                                 = var.app_container_ports
  container_images                                = var.app_container_images
  target_groups                                   = module.alb.target_group_arns
  mysqldb_discovery_service_name                  = module.servicediscovery.mysqldb_discovery_service_name
  mysqldb_discovery_service_registry_arn          = module.servicediscovery.mysqldb_discovery_service_registry_arn
  progress_tracker_discovery_service_name         = module.servicediscovery.progress_tracker_discovery_service_name
  progress_tracker_discovery_service_registry_arn = module.servicediscovery.progress_tracker_discovery_service_registry_arn
  jwt_access_token                                = var.jwt_access_token
  enable_blue_green_deployment                    = var.app_enable_blue_green_deployment
}

# --------------------------------------------------------------
# ECS EC2
# --------------------------------------------------------------
module "ecs_ec2" {
  source                                          = "./modules/ecs-ec2-cluster"
  app_name                                        = var.app_name
  stage_name                                      = var.stage_name
  ecs_task_execution_role_arn                     = module.iam.ecs_task_execution_role_arn
  ecs_ec2_instance_role_name                      = module.iam.ecs_ec2_instance_role_name
  regionid                                        = var.aws_regions[var.aws_region]
  ecs_ec2_cluster_name                            = var.ecs_ec2_cluster_name
  security_group_ids                              = module.sg.security_group_ids
  vpcid                                           = module.vpc.vpcid
  subnets                                         = module.vpc.private_subnet_ids
  container_ports                                 = var.app_container_ports
  container_images                                = var.app_container_images
  mysqldb_discovery_service_name                  = module.servicediscovery.mysqldb_discovery_service_name
  progress_tracker_discovery_service_registry_arn = module.servicediscovery.progress_tracker_discovery_service_registry_arn
  jwt_access_token                                = var.jwt_access_token
}

# --------------------------------------------------------------
# CI/CD 
# --------------------------------------------------------------

module "deployment" {
  source          = "./modules/deployment"
  app_name        = var.app_name
  stage_name      = var.stage_name
  cluster_name    = var.ecs_fargate_cluster_name
  service_names   = module.ecs_fargate.service_names
  target_groups   = module.alb.target_group_names
  listener_arns   = module.alb.listener_arns
  container_ports = var.app_container_ports
}

