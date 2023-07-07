variable "project" {
  description = "project"
  type        = string
  default     = "terraform-ga"
}

variable "key_name" {
  description = "key_name"
  type        = string
  default     = "DemoKeyPair"
}

variable "aws_region" {
  description = "aws_region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "instance_type"
  type        = string
  default     = "t2.micro"
}

variable "vpc_cidr_block" {
  description = "vpc_cidr_block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  description = "public_subnets_cidr"
  type        = list(any)
  default     = ["10.0.0.0/24", "10.0.2.0/24", "10.0.4.0/24"]
}

variable "azs" {
  description = "azs"
  type        = list(any)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "webservers_ami" {
  description = "webservers_ami"
  type        = string
  default     = "ami-06ca3ca175f37dd66" #Unbuntu - "ami-053b0d53c279acc90" || AmazonLinux - "ami-06ca3ca175f37dd66"
}

variable "max_size" {
  description = "max_size"
  type        = number
  default     = 6
}

variable "min_size" {
  description = "min_size"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "desired_capacity"
  type        = number
  default     = 3
}

variable "health_check_grace_period" {
  description = "health_check_grace_period"
  type        = number
  default     = 300
}

variable "asg_health_check_type" {
  description = "asg_health_check_type"
  type        = string
  default     = "ELB" #"ELB" or default EC2
}

variable "load_balancer_type" {
  description = "load_balancer_type"
  type        = string
  default     = "application"
}

variable "enable_deletion_protection" {
  description = "enable_deletion_protection"
  type        = bool
  default     = false
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
