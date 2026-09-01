resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}-vpc"
  }
}

resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.main.id

  cidr_block = count.index == 0 ? "10.0.1.0/24" : "10.0.2.0/24"

  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.name}-public-${var.availability_zones[count.index]}"
  }
}

resource "aws_subnet" "private_app" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.main.id

  cidr_block = count.index == 0 ? "10.0.11.0/24" : "10.0.12.0/24"

  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.name}-private-app-${var.availability_zones[count.index]}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-public-rt"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-private-app-rt"
  }
}

resource "aws_route_table_association" "private_app" {
  count = length(aws_subnet.private_app)

  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app.id
}

# 1. Allocate an Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main] # Ensures proper cleanup order

  tags = {
    Name = "main-nat-eip"
  }
}

# 2. Create the NAT Gateway in a Public Subnet
resource "aws_nat_gateway" "main" {
  count = length(aws_subnet.public)
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[count.index].id # Must be placed in a public subnet

  tags = {
    Name = "main-nat-gateway"
  }
}

# 4. Associate the Private Subnets with the Private Route Table
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private_app)
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app.id
}
