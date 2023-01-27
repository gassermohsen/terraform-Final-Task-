output "aws_public_instance-ip" {
  value = aws_instance.terraform-public-instance.*.id
}

output "aws_private_instance-ip" {
  value = aws_instance.terraform-private-instance.*.id
}

