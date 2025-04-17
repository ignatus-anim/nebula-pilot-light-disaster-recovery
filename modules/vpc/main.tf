resource "aws_vpc" "nebula_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-vpc"
  })
}

resource "aws_internet_gateway" "nebula_igw" {
  vpc_id = aws_vpc.nebula_vpc.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-igw"
  })
}

resource "aws_subnet" "nebula_public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.nebula_vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-public-${count.index + 1}"
  })
}

resource "aws_subnet" "nebula_private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.nebula_vpc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-private-${count.index + 1}"
  })
}


resource "aws_route_table" "nebula_public_rt" {
  vpc_id = aws_vpc.nebula_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nebula_igw.id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-public-rt"
  })
}

resource "aws_route_table_association" "nebula_public_rt_assoc" {
  count          = 2
  subnet_id      = aws_subnet.nebula_public_subnet[count.index].id
  route_table_id = aws_route_table.nebula_public_rt.id
}


resource "aws_route_table" "nebula_private_rt" {
  vpc_id = aws_vpc.nebula_vpc.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-private-rt"
  })
}


resource "aws_route_table_association" "nebula_private_rt_assoc" {
  count          = 2
  subnet_id      = aws_subnet.nebula_private_subnet[count.index].id
  route_table_id = aws_route_table.nebula_private_rt.id
}
