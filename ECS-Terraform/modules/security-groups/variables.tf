variable "app_name" {
  type = string
}
variable "stage_name" {
  type = string
}
variable "vpcid" {
  type = string
}
variable "container_ports" {
  type = map(number)
}
variable "alb_security_group_id" {
  type = string
}