
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform_key"
  public_key = tls_private_key.example.public_key_openssh

    provisioner "local-exec" {    # Generate "terraform-key-pair.pem" in current directory
    command = <<-EOT
      echo '${tls_private_key.example.private_key_pem}' > ./terraform_key.pem
      chmod 400 ./terraform_key.pem
    EOT
  }



}






resource "aws_security_group" "sec-group-terraform" {
  name        = "terraform-secgroup"
  description = "Security group for allowing http "
  vpc_id      = var.vpc_id

 ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [ var.all-trafic-cidr ]

  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.all-trafic-cidr]
  }
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.all-trafic-cidr]
  }
}

resource "aws_instance" "terraform-public-instance" {
  ami           = var.default-ami
  instance_type = var.default-instance-type
  count = length(var.public_subnet_id)
  subnet_id     = var.public_subnet_id[count.index]
  associate_public_ip_address = "true"
  key_name = aws_key_pair.terraform_key.key_name
  vpc_security_group_ids = [aws_security_group.sec-group-terraform.id ]

  provisioner "local-exec" {
    when = create
    command = "echo public-ip${count.index+1}  ${self.public_ip} >> ./all-ips.txt"
  }
  provisioner "remote-exec" {
     inline = var.provisioner-remote-exec-inline
  }

    connection {
      type =  "ssh"
      host = self.public_ip
      user = "ubuntu"
      private_key = file("./${aws_key_pair.terraform_key.key_name}.pem")
      timeout = "4m"
    }



#   user_data = <<-EOF
#   #!/bin/bash
#   echo "*** Installing apache2"
#   sudo apt update -y
#   sudo apt install apache2 -y
#   echo "*** Completed Installing apache2"
#   EOF

  tags = {
      count = length(var.public_subnet_id)

    Name = "terraform-public-instance - ${count.index}"
  }
}

resource "aws_instance" "terraform-private-instance" {
  ami           = var.default-ami
  instance_type = var.default-instance-type
  count = length(var.private_subnet_id)
  subnet_id     = var.private_subnet_id[count.index]
  vpc_security_group_ids = [aws_security_group.sec-group-terraform.id ]
  user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing apache2"
  sudo apt update -y
  sudo apt install apache2 -y
  echo "*** Completed Installing apache2"
  EOF

  tags = {
      count = length(var.private_subnet_id)
    Name = "terraform-private-instance - ${count.index}"
  }
}
 