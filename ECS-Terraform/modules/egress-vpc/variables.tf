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
  default = "10.192.0.0/20"
}
variable "public_subnets" {
  type    = list(string)
  default = ["10.192.0.0/24", "10.192.1.0/24"]
}
variable "private_subnets" {
  type    = list(string)
  default = ["10.192.2.0/24", "10.192.3.0/24"]
}

variable "nat_gateways" {
  type    = number
  default = 1
  description = "Number of NAT Gateways to be provisioned. This number cannot exceed the total number of Public Subnets in all AZs"
}

variable "transit_gateway_id" {
  type = string
}