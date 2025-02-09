# ----------------------
# target group
# ----------------------
resource "aws_lb_target_group" "web_tg" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

# ----------------------
# security group
# ----------------------
resource "aws_security_group" "alb_sg" {
  vpc_id   = var.vpc_id
  tags = {
    Name = "alb-sg"
  }

  ingress {
    description      = "Allow HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# ----------------------
# Application Load Balancer (ALB)
# ----------------------
resource "aws_lb" "web_alb" {
  name               = "web-alb"
  internal           = false  # インターネット向けなら false, 内部 ALB なら true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets           = var.subnet_ids

  enable_deletion_protection = false  # 本番環境では true にすることを推奨
}

# ----------------------
# ALB Listener (HTTP)
# ----------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "example" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = var.example_id
  port             = 80
}