resource "aws_security_group" "security_group" {
  count  = length(var.sg_list)
  name   = "SG-${var.sg_list[count.index]}"
  vpc_id = aws_vpc.vpc.id
  description = "Security Group for ${var.sg_list[count.index]}"

  tags = {
    Name = "SG-${var.sg_list[count.index]}"
    Description = "Security Group for ${var.sg_list[count.index]}"
  } 
}
