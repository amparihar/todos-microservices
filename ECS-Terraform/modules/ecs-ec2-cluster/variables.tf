variable "app_name" {
  type = string
}
variable "stage_name" {
  type = string
}
variable "ecs_task_execution_role_arn" {
  type = string
}
variable "ecs_ec2_instance_role_name" {
  type = string
}
variable "regionid" {
  type = string
}
variable "ecs_ec2_cluster_name" {
  type = string
}
variable "security_group_ids" {
  type = map(string)
}
variable "vpcid" {
  type = string
}
variable "subnets" {
  type = list(string)
}
variable "assign_public_ip" {
  type = bool
}
variable "container_ports" {
  type = map(number)
}
variable "container_images" {
  type = map(string)
}
variable "mysqldb_discovery_service_name" {
  type = string
}
variable "progress_tracker_discovery_service_registry_arn" {
  type = string
}
variable "max_instances" {
  type    = number
  default = 3
}
variable "min_instances" {
  type    = number
  default = 1
}
variable "desired_capacity" {
  type    = number
  default = 1
}
variable "instance_type" {
  type    = string
  default = "t2.medium"
}
variable "jwt_access_token" {
  type = string
}
