variable "app_name" {
  type = string
}
variable "stage_name" {
  type = string
}

variable "transit_gateway_id" {
  type = string
}

variable "todos_subnets" {
  type = list(string)
}

variable "todos_vpcid" {
  type = string
}

variable "ingress_subnets" {
  type = list(string)
}

variable "ingress_vpcid" {
  type = string
}

variable "egress_subnets" {
  type = list(string)
}

variable "egress_vpcid" {
  type = string
}

variable "app_cidr_blocks" {
  type = list
}