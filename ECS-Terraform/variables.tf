variable "app_name" {
  type    = string
  default = "mytodos"
}
variable "stage_name" {
  type    = string
  default = "nonprod"
}

variable "aws_region" {
  type    = string
  default = "ohio"
}
variable "aws_regions" {
  type = map(string)
  default = {
    mumbai        = "ap-south-1"
    northvirginia = "us-east-1"
    ohio          = "us-east-2"
  }
}
variable "ecs_fargate_cluster_name" {
  type        = string
  description = "Name of the ECS Fargate Cluster (up to 255 letters, numbers, hyphens, and underscores)"
  default     = "mytodos-fargate-kluster"
  validation {
    condition     = length(var.ecs_fargate_cluster_name) > 0
    error_message = "ECS Fargate Cluster Name is required."
  }
}
variable "ecs_ec2_cluster_name" {
  type        = string
  description = "Name of the ECS EC2 Linux Cluster (up to 255 letters, numbers, hyphens, and underscores)"
  default     = "mytodos-ec2-kluster"
  validation {
    condition     = length(var.ecs_ec2_cluster_name) > 0
    error_message = "ECS EC2 Linux Cluster Name is required."
  }
}
variable "app_container_ports" {
  type = map(number)
  default = {
    "user_microservice"             = 4096
    "group_microservice"            = 5096
    "task_microservice"             = 6096
    "progress_tracker_microservice" = 7096
    "mysql_db_microservice"         = 3306
    "front_end_microservice"        = 3000
  }
}

variable "app_container_images" {
  type = map(string)
  default = {
    user_microservice             = "aparihar/todos-user-microsvc:3.0"
    group_microservice            = "aparihar/todos-group-microsvc:4.4"
    task_microservice             = "aparihar/todos-task-microsvc:3.0"
    progress_tracker_microservice = "aparihar/todos-progress-tracker-microsvc:3.1"
    mysql_db_microservice         = "aparihar/todos-mysql-db-microsvc:latest"
    front_end_microservice        = "aparihar/todos-mytodos-microsvc-v2:latest"
  }
}

variable "jwt_access_token" {
  type = string
}

variable "app_enable_blue_green_deployment" {
  description = "Enable blue/ green deployment for the frontend microservice"
  type        = bool
  default     = false
}
