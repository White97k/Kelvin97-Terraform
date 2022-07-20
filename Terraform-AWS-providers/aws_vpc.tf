##create VPC network
resource "aws_vpc" "BaseNetworkVPC" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  
  tags = {
    Name = "BaseNetworkVPC"
  }
}