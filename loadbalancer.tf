resource "aws_lb" "this" {
  name               = "${var.project}-lb"
  internal           = false
  load_balancer_type = var.load_balancer_type #"application" or "network"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for subnet in aws_subnet.public_subnet : subnet.id]

  enable_deletion_protection = var.enable_deletion_protection #true

  #   access_logs {
  #     bucket  = aws_s3_bucket.lb_logs.bucket
  #     prefix  = "test-lb"
  #     enabled = true
  #   }

  tags = merge({ "Name" = "${var.project}-lb" }, var.tags)
}

resource "aws_lb_target_group" "this" {
  name        = "${var.project}-lb-tg"
  port        = var.lb_target_port
  protocol    = var.lb_protocol    #"HTTP"
  target_type = var.lb_target_type #"ip" for ALB/NLB, "instance" for autoscaling group, 
  vpc_id      = aws_vpc.main_vpc.id
  tags        = merge({ "Name" = "${var.project}-lb-tg" }, var.tags)
  depends_on  = [aws_lb.this]

  lifecycle {
    create_before_destroy = true
  }

  #   health_check {
  #     path = "/"
  #     port = 80
  #   }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.lb_listener_port     #"443"
  protocol          = var.lb_listener_protocol #"TLS"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  #alpn_policy       = "HTTP2Preferred"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_target_group_attachment" "this" {
  count            = length(data.aws_instances.this.ids)
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = data.aws_instances.this.ids[count.index] #data.aws_instance.this.id
  port             = var.lb_target_port                       # 80
}

# autoscaling attachment  
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.this.id
}