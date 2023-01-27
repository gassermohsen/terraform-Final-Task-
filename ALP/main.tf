resource "aws_security_group" "ALP_sg" {
  name        = "Application-loadBalancer-1"
  description = "Application load balancer for public ec2"
  vpc_id      = var.vpc_id

 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
}

resource "aws_lb_target_group" "tg" {
  name     = "ALP-TargetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "target_group_attach" {
  target_group_arn = aws_lb_target_group.tg.arn
  count = length(var.tg_ec2_ids)
  target_id        = var.tg_ec2_ids[count.index]
  port             = 80
}

resource "aws_lb" "terraform-alp" {
  name               = var.ALP_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [ aws_security_group.ALP_sg.id ]
  subnets            =  var.public_subnet_ids 
}


resource "aws_lb_listener" "ALP_listener" {
  load_balancer_arn = aws_lb.terraform-alp.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}