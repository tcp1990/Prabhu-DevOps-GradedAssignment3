# vpc
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# internet gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "main-igw"
  }
}

# subnets : public
resource "aws_subnet" "public_subnet" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-pub-${count.index + 1}"
  }
}

# subnets : private
resource "aws_subnet" "private_subnet" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-priv-${count.index + 1}"
  }
}

# route table: public
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "public_route_table"
  }
}

# route: public
resource "aws_route" "public_route" {
  gateway_id             = aws_internet_gateway.main_igw.id
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public_rt.id
}

# associate route table with vpc
resource "aws_main_route_table_association" "public_mrta" {
  vpc_id         = aws_vpc.main_vpc.id
  route_table_id = aws_route_table.public_rt.id
}

# route table association with public subnets
resource "aws_route_table_association" "public_rt_association" {
  count          = length(var.azs)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

# create elastic IP (EIP) to assign it the NAT Gateway 
resource "aws_eip" "public_eip" {
  count      = length(var.azs)
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main_igw]
}

# create NAT Gateways: public
resource "aws_nat_gateway" "public_ng" {
  count         = length(var.azs)
  allocation_id = element(aws_eip.public_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)
  depends_on    = [aws_internet_gateway.main_igw]
}

# for each of the private ranges, create a "private" route table.
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id
  count  = length(var.azs)
  tags = {
    Name = "private_subnet_route_table_${count.index + 1}"
  }
}

# add a nat gateway to each private subnet's route table
resource "aws_route" "private_nat_gateway_route" {
  count                  = length(var.azs)
  route_table_id         = element(aws_route_table.private_rt.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_route_table.private_rt]
  nat_gateway_id         = element(aws_nat_gateway.public_ng.*.id, count.index)
}
