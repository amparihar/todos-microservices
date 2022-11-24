resource "aws_ec2_transit_gateway" "main" {
  description = "Egress gateway"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  
  tags = {
      Name = format("tgw-%s-%s",var.app_name,var.stage_name)
  }
}

output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.main.id
}