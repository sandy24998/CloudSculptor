resource "aws_vpc" "main-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
      Name = "${var.environment}-vpc"
}
}

resource "aws_subnet" "public-subnet" {
  count = length(var.public_subnets)
  vpc_id = aws_vpc.main-vpc.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-${var.availability_zones[count.index]}"
    Type = "Public"
  }
}

resource "aws_subnet" "private-subnet" {
  count = length(var.private_subnets)
  vpc_id = aws_vpc.main-vpc.id
  cidr_block = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.environment}-private-${var.availability_zones[count.index]}"
    Type = "private"
  }

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "${var.environment}-igw"
  }

}

resource "aws_eip" "nat" {
  count  = length(var.public_subnets)
  domain = "vpc"

  tags = {
    Name = "${var.environment}-nat-eip-${count.index}"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat" {
  count = length(var.public_subnets)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id = aws_subnet.public-subnet[count.index].id
   tags = {
    Name = "${var.environment}-nat-${var.availability_zones[count.index]}"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main-vpc.id
  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.id
  }
  tags = {
    Name = "${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
count = length(aws_subnet.public-subnet[*].id)
subnet_id = aws_subnet.public-subnet[count.index].id
route_table_id = aws_route_table.public-route-table.id
}