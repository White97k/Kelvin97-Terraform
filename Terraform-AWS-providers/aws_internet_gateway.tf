resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.BaseNetworkVPC.id
  tags = {
    Name = "${var.account}_igw"
  }
}