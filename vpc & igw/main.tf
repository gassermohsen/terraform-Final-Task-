resource "aws_vpc" "terraform" {
  cidr_block = var.vpc-cidr
  tags = {
    "Name" = "Terraform"
  }
}


resource "aws_internet_gateway" "internetgatway" {
  vpc_id = aws_vpc.terraform.id

  tags = {
    Name = "Terraform internetgateway"
  }
}