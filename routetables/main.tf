
resource "aws_route_table" "terraform-route-table" {
  vpc_id = var.vpc-id

  route {
    cidr_block = var.all-trafic-cidr
    gateway_id = var.internet-gateway-id
  }

  tags = {
    Name = "internetgatway-routetable"
  }
}

resource "aws_route_table_association" "public-subnet-association" {
  subnet_id      = var.public-subnet-assos-1
  route_table_id = aws_route_table.terraform-route-table.id
}

resource "aws_route_table_association" "public-subnet-association-2" {
  subnet_id      = var.public-subnet-assos-2
  route_table_id = aws_route_table.terraform-route-table.id
}


#   Nat gatway route table 

resource "aws_route_table" "terraform-natgatway-route-table" {
  vpc_id = var.vpc-id

  route {
    nat_gateway_id = var.nat_gateway_id
    cidr_block = var.all-trafic-cidr
 
  }

  tags = {
    Name = "terraform-routetable"
  }
}

resource "aws_route_table_association" "natgatway-private1-subnet-association" {
  subnet_id      = var.nat-private-subnet-assos-1
  route_table_id = aws_route_table.terraform-natgatway-route-table.id

}

resource "aws_route_table_association" "natgatway-private2-subnet-association" {
  subnet_id      = var.nat-private-subnet-assos-2
  route_table_id = aws_route_table.terraform-natgatway-route-table.id

}

