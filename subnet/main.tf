resource "aws_subnet" "subnets" {
  count = length(var.subnet-cidr)
  vpc_id     = var.vpc-id
  cidr_block = var.subnet-cidr[count.index]
  availability_zone = var.availability_zone[count.index]
  
  tags = {
    count = length(var.subnet-names)
    Name = "${var.subnet-names[count.index]}"
  }
}