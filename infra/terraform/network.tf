data "aws_availability_zones" "disponibles" {
  state = "available"
}

locals {
  zonas = slice(data.aws_availability_zones.disponibles.names, 0, 2)
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.nombre}-vpc" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.nombre}-igw" }
}

resource "aws_subnet" "publica" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  availability_zone       = local.zonas[count.index]
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 1)
  map_public_ip_on_launch = true
  tags = {
    Name                     = "${var.nombre}-publica-${local.zonas[count.index]}"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "privada" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  availability_zone = local.zonas[count.index]
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 11)
  tags = {
    Name                              = "${var.nombre}-privada-${local.zonas[count.index]}"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "${var.nombre}-rt-publica" }
}

resource "aws_route_table_association" "publica" {
  count          = 2
  subnet_id      = aws_subnet.publica[count.index].id
  route_table_id = aws_route_table.publica.id
}

resource "aws_route_table" "privada" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.nombre}-rt-privada" }
}

resource "aws_route_table_association" "privada" {
  count          = 2
  subnet_id      = aws_subnet.privada[count.index].id
  route_table_id = aws_route_table.privada.id
}
