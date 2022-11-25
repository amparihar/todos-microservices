variable "app_name" {
  type = string
}
variable "stage_name" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.200.0.0/20"
}
variable "public_subnets" {
  type    = list(string)
  default = ["10.200.0.0/24", "10.200.1.0/24"]
}
variable "transit_gateway_id" {
  type = string
}