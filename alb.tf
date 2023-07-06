# security group for EC2 instances
resource "aws_security_group" "webserver_sg" {
  name        = "webserver-sg"
  description = "Security group for my web server"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# security group for application load balancer
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for my ALB"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "alb-security-group"
  }
}

# using ALB - instances in private subnets
resource "aws_lb" "main_alb" {
  name                       = "main-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = [for subnet in aws_subnet.private_subnet : subnet.id]
  enable_deletion_protection = true
  tags = {
    Name = "main-alb"
  }
}

# listener
resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.main_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alb_tg.arn
    type             = "forward"
  }
}

# alb target group
resource "aws_alb_target_group" "alb_tg" {
  name     = "alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
  health_check {
    path = "/"
    port = 80
  }
}

# creating launch template
resource "aws_launch_template" "launch_template" {
  name          = "launch_template"
  image_id      = var.webservers_ami
  instance_type = var.instance_type
  key_name      = "DemoKeyPair"
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.webserver_sg.id]
    delete_on_termination       = true
  }
  user_data = filebase64("user_data.sh")
  lifecycle {
    create_before_destroy = true
  }
}

# creating autoscaling group
resource "aws_autoscaling_group" "main_asg" {
  name                = "main-autoscaling-group"
  vpc_zone_identifier = [for subnet in aws_subnet.private_subnet : subnet.id]
  desired_capacity    = 3
  max_size            = 6
  min_size            = 1
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }

  tag {
    key                 = "Name"
    value               = "main-asg"
    propagate_at_launch = true
  }
}

# autoscaling attachment  
resource "aws_autoscaling_attachment" "asg_attachment" {
  lb_target_group_arn    = aws_alb_target_group.alb_tg.arn
  autoscaling_group_name = aws_autoscaling_group.main_asg.id
}


# ALB DNS is generated dynamically, return URL so that it can be used
output "url" {
  value = "http://${aws_lb.main_alb.dns_name}/"
}
