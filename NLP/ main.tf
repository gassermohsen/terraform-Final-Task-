resource "aws_lb_target_group" "tg" {
  name     = "NLP-TargetGroup"
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "target_group_attach" {
  target_group_arn = aws_lb_target_group.tg.arn
  count = length(var.tg_private-ec2_ids)
  target_id        = var.tg_private-ec2_ids[count.index]
  port             = 80
}

resource "aws_lb" "terraform-nlp" {
  name               = var.NLP_name
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids 
}


resource "aws_lb_listener" "NLP_listener" {
  load_balancer_arn = aws_lb.terraform-nlp.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}