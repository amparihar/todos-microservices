locals {
  azs        = data.aws_availability_zones.available.names
  create_vpc = var.create_vpc && length(var.vpc_cidr) > 0 && length(var.public_subnets) > 0
}

resource "aws_vpc" "ingress" {
  count      = local.create_vpc ? 1 : 0
  cidr_block = var.vpc_cidr
  # dns settings are required to enable private hosted zone in VPC(i.e service discovery)
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-ingress-${var.app_name}-${var.stage_name}-${count.index + 1}"
  }
}

# One public subnet in each of the 2 AZs
resource "aws_subnet" "public" {
  count                   = local.create_vpc ? length(slice(local.azs, 0, 2)) : 0
  vpc_id                  = element(aws_vpc.egress.*.id, 0)
  availability_zone       = element(local.azs, count.index)
  cidr_block              = element(var.public_subnets, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-ingress-${var.app_name}-${var.stage_name}-${local.azs[count.index]}-${count.index + 1}"
    Tier = "Public"
  }
}

resource "aws_internet_gateway" "this" {
  count  = local.create_vpc ? 1 : 0
  vpc_id = aws_vpc.ingress[0].id

  tags = {
    Name = "igw-ingress-${var.app_name}-${var.stage_name}-${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  count  = local.create_vpc ? 1 : 0
  vpc_id = element(aws_vpc.ingress.*.id, 0)
  
  # default
  route {
      cidr_block    = "0.0.0.0/0"
      gateway_id    = element(aws_internet_gateway.this.*.id, count.index)
  }
  
  # todos
  dynamic "route" {
      for_each = var.app_cidr_blocks
      content {
          cidr_block            = route.value
          transit_gateway_id    = var.transit_gateway_id
      }
  }
}

resource "aws_route_table_association" "public" {
  count          = local.create_vpc ? length(slice(local.azs, 0, 2)) : 0
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
}

output "vpcid" {
  value = element(aws_vpc.ingress.*.id, 0)
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}