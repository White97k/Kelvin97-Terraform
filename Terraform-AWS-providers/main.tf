terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"  ##edit##
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "ap-southeast-1"  ##edit##
}

resource "aws_instance" "testapp_server" {   ##aws_instance = resource-type ; testapp_server = resource-name
  ami           = "ami-xxx"  ##edit##
  instance_type = "t2.micro"
  vpc_security_group_ids = "sg-xxx"  ##your security-group
  subnet_id = "subnet-xxx"  ##your subnet

  tags = {
    Name = "testapp_server"  ##your EC2-instance tags name
  }
}
