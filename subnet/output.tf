 output "subnets-ids" {
  value = aws_subnet.subnets.*.id
 }