##create VPC network
resource "aws_vpc" "mainvpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  
  tags = {
    Name = "mainvpc"
  }
}

#dfdsfshfsoifisdo