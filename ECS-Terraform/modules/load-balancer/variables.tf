variable "app_name" {
  type = string
}
variable "stage_name" {
  type = string
}
variable "create_alb" {
  type    = bool
  default = true
}
variable "vpcid" {
  type = string
}
variable "subnets" {
  type = list(string)
}
variable "listener_path_patterns" {
  type = map(list(string))
  default = {
    "user_microservice"      = ["/api/user*"]
    "group_microservice"     = ["/api/group*"]
    "task_microservice"      = ["/api/task*"]
    "front_end_microservice" = ["/*"]
  }
}
variable "target_group_health_check_path" {
  type = map(string)
  default = {
    "user_microservice"      = "/api/user/health-check"
    "group_microservice"     = "/api/group/health-check"
    "task_microservice"      = "/api/task/health-check"
    "front_end_microservice" = "/index.html"
  }
}
variable "enable_blue_green_deployment" {
  type = bool
}
