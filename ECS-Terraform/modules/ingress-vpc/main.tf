locals {
  azs = data.aws_availability_zones.available.names
}

resource "aws_vpc" "main" {
  
  cidr_block = var.vpc_cidr
  # dns settings are required to enable private hosted zone in VPC(i.e service discovery)
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-ingress-${var.app_name}-${var.stage_name}"
  }
}

# One public subnet in each of the 2 AZs
resource "aws_subnet" "public" {
  count                   = length(slice(local.azs, 0, 2)) : 0
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(local.azs, count.index)
  cidr_block              = element(var.public_subnets, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-ingress-${var.app_name}-${var.stage_name}-${local.azs[count.index]}-${count.index + 1}"
    Tier = "Public"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw-ingress-${var.app_name}-${var.stage_name}}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route" "public_tgw" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "10.100.0.0/20"
  transit_gateway_id        = var.transit_gateway_id
}

resource "aws_route_table_association" "public" {
  count          = length(slice(local.azs, 0, 2)) : 0
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}
