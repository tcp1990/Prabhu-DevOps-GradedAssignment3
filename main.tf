terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.6.2"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Filter to fetch multiple instances : aws_instances
data "aws_instances" "this" {
  filter {
    name   = "tag:${var.lb_target_tags_map["name"]}"
    values = ["${var.lb_target_tags_map["value"]}"]
  }
}