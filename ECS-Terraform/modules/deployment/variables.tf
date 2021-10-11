variable "app_name" {
  type = string
}
variable "stage_name" {
  type = string
}
variable "create_cmk" {
  type    = bool
  default = false
}
variable "cluster_name" {
  type = string
}
variable "service_names" {
  type = map(string)
}
variable "target_groups" {
  type = map(string)
}
variable "listener_arns" {
  type = map(string)
}
variable "container_ports" {
  type = map(string)
}
variable "blue_green_deployment_configurations" {
  type = map(string)
  default = {
    "linear_10p_1m"  = "CodeDeployDefault.ECSLinear10PercentEvery1Minutes"
    "linear_10p_3m"  = "CodeDeployDefault.ECSLinear10PercentEvery3Minutes"
    "canary_10p_5m"  = "CodeDeployDefault.ECSCanary10Percent5Minutes"
    "canary_10p_15m" = "CodeDeployDefault.ECSCanary10Percent15Minutes"
    "all_at_once"    = "CodeDeployDefault.ECSAllAtOnce" # default
  }
}

variable "frontend_microservice_deployment_configuration_name" {
  type = string
  default = "canary_10p_5m"
}
