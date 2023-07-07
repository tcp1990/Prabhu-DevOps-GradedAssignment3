variable "project" {
  default = "terraform-ga"
}

variable "key_name" {
  default = "DemoKeyPair"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  default = ["10.0.0.0/24", "10.0.2.0/24", "10.0.4.0/24"]
}

variable "azs" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "webservers_ami" {
  description = "webservers_ami"
  type        = string
  default     = "ami-053b0d53c279acc90"
}

variable "max_size" {
  default = 6
}

variable "min_size" {
  default = 1
}

variable "desired_capacity" {
  default = 3
}

variable "health_check_grace_period" {
  default = 300
}

variable "asg_health_check_type" {
  default = "ELB" #"ELB" or default EC2
}

variable "load_balancer_type" {
  default = "application"
}

variable "enable_deletion_protection" {
  default = false
}

variable "lb_target_port" {
  description = "lb_target_port 80 or 443"
  type        = number
  default     = 80
}

variable "lb_protocol" {
  description = "lb_protocol HTTP (ALB) or TCP (NLB)"
  type        = string
  default     = "HTTP"
}

variable "lb_target_type" {
  description = "Target type ip (ALB/NLB), instance (Autosaling group)"
  type        = string
  default     = "instance"
}

variable "lb_listener_port" {
  description = "lb_listener_port"
  type        = number
  default     = 80
}

variable "lb_listener_protocol" {
  description = "lb_listener_protocol HTTP, TCP, TLS"
  type        = string
  default     = "HTTP"
}

variable "tags" {
  default = {}
}
