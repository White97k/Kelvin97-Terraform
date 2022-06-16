terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.18"
    }
  }
}

provider "aws" {
  profile = "testing"
  region  = "ap-southeast-1"
}

##create VPC network
resource "aws_vpc" "mainvpc" {
  cidr_block = "172.85.0.0/21"
  tags       = {
    Name = "mainvpc"
  }
}

##create IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mainvpc.id
  tags   = {
    Name = "mainigw"
  }
}

##create route_table (public-network)
resource "aws_route_table" "pub-route_table" {
  vpc_id = aws_vpc.mainvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "pub-route_table"
  }
}


##create Subnet (public-network)
resource "aws_subnet" "pubsub1a" {
  vpc_id     = aws_vpc.mainvpc.id
  cidr_block = "172.85.1.0/24"

  tags = {
    Name = "Public Subnet 1A"
  }
}

##associate subnet to rtb
resource "aws_route_table_association" "subnettortb" {
  subnet_id      = aws_subnet.pubsub1a.id
  route_table_id = aws_route_table.pub-route_table.id
}


##create ec2-instance
#resource "aws_instance" "app_server" {
#  ami           = "ami-0bd6906508e74f692"
#  instance_type = "t2.micro"
#
#  tags = {
#    Name = "app-server"
#  }
#}
