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