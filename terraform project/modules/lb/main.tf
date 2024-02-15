resource "aws_lb" "alb_front_end" {
  name               = "frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_frontend_sg.id]
  subnets            = [aws_subnet.public_subnet.id]
  enable_deletion_protection = false
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb_front_end.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}

resource "aws_lb_target_group" "front_end" {
  name     = "frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb" "alb_back_end" {
  name               = "backend-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_backend_sg.id]
  subnets            = [aws_subnet.private_subnet.id]
  enable_deletion_protection = false
}

resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.alb_back_end.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.back_end.arn
  }
}

resource "aws_lb_target_group" "back_end" {
  name     = "backend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}
