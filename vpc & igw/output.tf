output "vpc-id" {
  value = aws_vpc.terraform.id
  
}

output "internetgateway-id" {
  value = aws_internet_gateway.internetgatway.id
}