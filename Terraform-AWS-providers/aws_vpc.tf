# Configure the AWS Provider
provider "aws" {
  region = var.aws_region ##edit
}
#Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}
#Define the VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr ##edit
  tags = {
    Name        = var.vpc_name ##edit
  }
}
#Deploy the private subnets
resource "aws_subnet" "private_subnets" {
  count = 3
  vpc_id            = aws_vpc.vpc.id ##edit
  cidr_block        = cidrsubnet(var.vpc_cidr, 3, count.index)
  availability_zone = tolist(data.aws_availability_zones.available.names)[count.index]
  tags = {
    Name      = "private_subnets${count.index + 1}"
  }
}
#Deploy the public subnets
resource "aws_subnet" "public_subnets" {
  count = 3
  vpc_id            = aws_vpc.vpc.id ##edit
  cidr_block        = cidrsubnet(var.vpc_cidr, 3, count.index + 3)
  availability_zone = tolist(data.aws_availability_zones.available.names)[count.index]
  tags = {
    Name      = "public_subnets${count.index + 1}"
  }
}
#Create route tables for public and private subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
    #nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name      = "demo_public_rtb"
  }
}
resource "aws_route_table" "private_route_tables" {
    count = 3
  depends_on = [aws_subnet.private_subnets]
  vpc_id     = aws_vpc.vpc.id 
  route {
    cidr_block = "0.0.0.0/0"
    # gateway_id = aws_internet_gateway.internet_gateway.id
    nat_gateway_id = aws_nat_gateway.nat_gateways[count.index].id
  }
  tags = {
    Name      = "demo-private_route_tables${count.index + 1}"
  }
}

#Create route table associations
resource "aws_route_table_association" "public1" {
  depends_on     = [aws_subnet.public_subnets]
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnets[0].id
}
resource "aws_route_table_association" "public2" {
  depends_on     = [aws_subnet.public_subnets]
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnets[1].id
}
resource "aws_route_table_association" "public3" {
  depends_on     = [aws_subnet.public_subnets]
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnets[2].id
}
resource "aws_route_table_association" "privates" {
  count = 3
  depends_on = [aws_subnet.private_subnets]
  subnet_id = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_tables[count.index].id
}
#Create Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "demo_igw"
  }
}
#Create EIP for NAT Gateway
resource "aws_eip" "nat_gateway_eips" {
  count = 3
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "demo-nat_gateway_eip${count.index + 1}"
  }
}
#Create NAT Gateway
resource "aws_nat_gateway" "nat_gateways" {
  count = 3
  depends_on    = [aws_subnet.public_subnets]
  allocation_id = aws_eip.nat_gateway_eips[count.index].id
  subnet_id = aws_subnet.public_subnets[count.index].id
  tags = {
    Name = "demo_nat_gateway${count.index + 1}"
  }
}
