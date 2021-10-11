variable "app_name" {
  type = string
}
variable "stage_name" {
  type = string
}
variable "ecs_task_role_arn" {
  type = string
}
variable "ecs_task_execution_role_arn" {
  type = string
}
variable "regionid" {
  type = string
}
variable "ecs_fargate_cluster_name" {
  type = string
}
variable "security_group_ids" {
  type = map(string)
}
variable "subnets" {
  type = list(string)
}
variable "alb_dns_name" {
  type = string
}
variable "target_groups" {
  type = map(string)
}
variable "mysqldb_discovery_service_registry_arn" {
  type = string
}
variable "mysqldb_discovery_service_name" {
  type = string
}

variable "progress_tracker_discovery_service_registry_arn" {
  type = string
}
variable "progress_tracker_discovery_service_name" {
  type = string
}

# Verify supported task CPU and memory values for tasks that are hosted on Fargate 
variable "task_cpu" {
  type = map(string)
  default = {
    "user_microservice"             = "256"
    "group_microservice"            = "256"
    "task_microservice"             = "256"
    "progress_tracker_microservice" = "256"
    "mysql_db_microservice"         = "1024"
    "front_end_microservice"        = "512"
  }
}
variable "task_memory" {
  type = map(string)
  default = {
    "user_microservice"             = "512"
    "group_microservice"            = "512"
    "task_microservice"             = "512"
    "progress_tracker_microservice" = "512"
    "mysql_db_microservice"         = "2048"
    "front_end_microservice"        = "1024"
  }
}
variable "container_ports" {
  type = map(number)
}
variable "jwt_access_token" {
  type = string
}
variable "container_images" {
  type = map(string)
}
variable "enable_blue_green_deployment" {
  type = bool
}
