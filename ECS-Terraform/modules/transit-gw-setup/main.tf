

# resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
#   count                 = length(var.vpc_attachment)
#   subnet_ids            = var.vpc_attachment[count.index].subnets
#   transit_gateway_id    = transit_gateway_id
#   vpc_id                = ar.vpc_attachment[count.index].vpcid
  
#   transit_gateway_default_route_table_association = false
#   transit_gateway_default_route_table_propagation = false
  
#   tags = {
#       Name = format("tgwatt%s-%s-%s",var.vpc_attachment[count.index].key,var.app_name,var.stage_name)
#   }
  
#   depends_on = ["aws_ec2_transit_gateway.main"]
# }

resource "aws_ec2_transit_gateway_vpc_attachment" "todos" {
  
  subnet_ids            = var.todos_subnets
  transit_gateway_id    = var.transit_gateway_id
  vpc_id                = var.todos_vpcid
  
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  
  tags = {
      Name = format("tgw-att-todos-%s-%s",var.app_name,var.stage_name)
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "ingress" {
  
  subnet_ids            = var.ingress_subnets
  transit_gateway_id    = var.transit_gateway_id
  vpc_id                = var.ingress_vpcid
  
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  
  tags = {
      Name = format("tgw-att-ingress-%s-%s",var.app_name,var.stage_name)
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "egress" {
  
  subnet_ids            = var.egress_subnets
  transit_gateway_id    = var.transit_gateway_id
  vpc_id                = var.egress_vpcid
  
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  
  tags = {
      Name = format("tgw-att-egress-%s-%s",var.app_name,var.stage_name)
  }
}

resource "aws_ec2_transit_gateway_route_table" "todos" {
  transit_gateway_id = var.transit_gateway_id
  
  tags = {
    Name = format("tgw-route-table-outgoing-traffic-%s-%s",var.app_name,var.stage_name)
    Direction = "outgoing"
  }
}

resource "aws_ec2_transit_gateway_route_table" "ingress" {
  transit_gateway_id = var.transit_gateway_id
  tags = {
    Name = format("tgw-route-table-ingress-traffic-%s-%s",var.app_name,var.stage_name)
    Direction = "todos"
  }
}

resource "aws_ec2_transit_gateway_route_table" "egress" {
  transit_gateway_id = var.transit_gateway_id
  tags = {
    Name = format("tgw-route-table-returning-traffic-%s-%s",var.app_name,var.stage_name)
    Direction = "returning"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "todos" {
  transit_gateway_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.todos.id
  transit_gateway_route_table_id  = aws_ec2_transit_gateway_route_table.todos.id
}

resource "aws_ec2_transit_gateway_route_table_association" "ingress" {
  transit_gateway_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.ingress.id
  transit_gateway_route_table_id  = aws_ec2_transit_gateway_route_table.ingress.id
}

resource "aws_ec2_transit_gateway_route_table_association" "egress" {
  transit_gateway_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.egress.id
  transit_gateway_route_table_id  = aws_ec2_transit_gateway_route_table.egress.id
}

# resource "aws_ec2_transit_gateway_route_table_propagation" "todos" {
#   transit_gateway_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.todos.id
#   transit_gateway_route_table_id  = aws_ec2_transit_gateway_route_table.todos.id
# }

# resource "aws_ec2_transit_gateway_route_table_propagation" "ingress" {
#   transit_gateway_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.ingress.id
#   transit_gateway_route_table_id  = aws_ec2_transit_gateway_route_table.ingress.id
# }

# resource "aws_ec2_transit_gateway_route_table_propagation" "egress" {
#   transit_gateway_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.egress.id
#   transit_gateway_route_table_id  = aws_ec2_transit_gateway_route_table.egress.id
# }

resource "aws_ec2_transit_gateway_route" "todos_outgoing_traffic" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.todos.id
}

resource "aws_ec2_transit_gateway_route" "egress_returning_traffic" {
  count                           = length(var.app_cidr_blocks)
  destination_cidr_block          = var.app_cidr_blocks[count.index]
  transit_gateway_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.todos.id
  transit_gateway_route_table_id  = aws_ec2_transit_gateway_route_table.egress.id
}

resource "aws_ec2_transit_gateway_route" "ingress_outgoing_traffic" {
  count                           = length(var.app_cidr_blocks)
  destination_cidr_block          = var.app_cidr_blocks[count.index]
  transit_gateway_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.todos.id
  transit_gateway_route_table_id  = aws_ec2_transit_gateway_route_table.ingress.id
}

resource "aws_ec2_transit_gateway_route" "ingress_returning_traffic" {
  
  destination_cidr_block          = "10.190.0.0/20"
  transit_gateway_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.ingress.id
  transit_gateway_route_table_id  = aws_ec2_transit_gateway_route_table.todos.id
}