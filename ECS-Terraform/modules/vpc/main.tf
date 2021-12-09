locals {
  azs        = data.aws_availability_zones.available.names
  create_vpc = var.create_vpc && length(var.vpc_cidr) > 0 && length(var.public_subnets) > 0
  create_private_subnets = local.create_vpc && length(var.private_subnets) > 0 && var.nat_gateways > 0 && (var.nat_gateways <= length(var.private_subnets))
}

resource "aws_vpc" "main" {
  count      = local.create_vpc ? 1 : 0
  cidr_block = var.vpc_cidr
  # dns settings are required to enable private hosted zone in VPC(i.e service discovery)
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-${var.app_name}-${var.stage_name}-${count.index + 1}"
  }
}

# One public subnet in each of the 2 AZs
resource "aws_subnet" "public" {
  count                   = local.create_vpc ? length(slice(local.azs, 0, 2)) : 0
  vpc_id                  = element(aws_vpc.main.*.id, 0)
  availability_zone       = element(local.azs, count.index)
  cidr_block              = element(var.public_subnets, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${var.app_name}-${var.stage_name}-${local.azs[count.index]}-${count.index + 1}"
    Tier = "Public"
  }
}

resource "aws_internet_gateway" "main" {
  count  = local.create_vpc ? 1 : 0
  vpc_id = aws_vpc.main[0].id

  tags = {
    Name = "igw-${var.app_name}-${var.stage_name}-${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  count  = local.create_vpc ? 1 : 0
  vpc_id = element(aws_vpc.main.*.id, 0)
}

resource "aws_route" "public" {
  count                  = local.create_vpc ? 1 : 0
  route_table_id         = element(aws_route_table.public.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = element(aws_internet_gateway.main.*.id, count.index)
}

resource "aws_route_table_association" "public" {
  count          = local.create_vpc ? length(var.public_subnets) : 0
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
}

# private subnets

resource "aws_subnet" "private" {
  count             = local.create_vpc ? length(slice(local.azs, 0, 2)) : 0
  vpc_id            = element(aws_vpc.main.*.id, 0)
  availability_zone = element(local.azs, count.index)
  cidr_block        = element(var.private_subnets, count.index)

  tags = {
    Name = "private-subnet-${var.app_name}-${var.stage_name}-${local.azs[count.index]}-${count.index + 1}"
    Tier = "Private"
  }
}

resource "aws_route_table" "private" {
  count  = local.create_vpc ? length(var.private_subnets) : 0
  vpc_id = aws_vpc.main[0].id
}

resource "aws_route" "private" {
  count                  = local.create_vpc ? length(var.private_subnets) : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.main.*.id, count.index)
  depends_on = [
    aws_nat_gateway.main
  ]
}

resource "aws_route_table_association" "private" {
  count          = local.create_vpc ? length(var.private_subnets) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

#NAT G/W
resource "aws_nat_gateway" "main" {
  count         = local.create_vpc ? var.nat_gateways : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "natgw-${var.app_name}-${var.stage_name}-${count.index + 1}"
  }
}

resource "aws_eip" "nat" {
  count      = local.create_vpc ? var.nat_gateways : 0
  vpc        = true
  depends_on = [aws_internet_gateway.main]
  tags = {
    Name = "eip-${var.app_name}-${var.stage_name}-${count.index + 1}"
  }
}

output "avalability_zones" {
  value = slice(local.azs,0,length(local.azs))
}

output "vpcid" {
  value = element(aws_vpc.main.*.id, 0)
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}
