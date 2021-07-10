variable "app_name" {
  type = string
}
variable "stage_name" {
  type = string
}
variable "ecs_cluster_name" {
  type = string
}
variable "vpcid" {
  type = string
}
variable "subnets" {
  type = list(string)
}
variable "alb_security_group_id" {
  type = string
}
variable "alb_dns_name" {
  type = string
}
variable "target_groups" {
  type = map(string)
}
variable "mysqldb_registry_arn" {
  type = string
}
variable "mysqldb_service_name" {
  type = string
}

# Verify supported task CPU and memory values for tasks that are hosted on Fargate 
variable "task_cpu" {
  type = map(string)
  default = {
    "user_microservice"      = "256"
    "group_microservice"     = "256"
    "task_microservice"      = "256"
    "mysql_db_microservice"  = "1024"
    "front_end_microservice" = "512"
  }
}
variable "task_memory" {
  type = map(string)
  default = {
    "user_microservice"      = "512"
    "group_microservice"     = "512"
    "task_microservice"      = "512"
    "mysql_db_microservice"  = "2048"
    "front_end_microservice" = "1024"
  }
}
variable "container_ports" {
  type = map(number)
  default = {
    "user_microservice"      = 4096
    "group_microservice"     = 5096
    "task_microservice"      = 6096
    "mysql_db_microservice"  = 3306
    "front_end_microservice" = 80
  }
}
variable "jwt_access_token" {
  type = string
}