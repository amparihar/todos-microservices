variable "app_name" {
  type = string
}
variable "stage_name" {
  type = string
}
variable "create_vpc" {
  type    = bool
  default = true
}
variable "vpc_cidr" {
  type    = string
  default = "10.190.0.0/20"
}
variable "public_subnets" {
  type    = list(string)
  default = ["10.190.0.0/24", "10.190.1.0/24"]
}
variable "transit_gateway_id" {
  type = string
}
variable "app_cidr_blocks" {
  type = list
}