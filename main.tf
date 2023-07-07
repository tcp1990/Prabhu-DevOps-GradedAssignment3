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

locals {
  tags = {
    Project     = var.project
    CreatedOn   = timestamp()
    Environment = terraform.workspace
  }
}

# Filter to fetch multiple instances : aws_instances
data "aws_instances" "this" {
  filter {
    name   = "image-id"
    values = [var.webservers_ami]
  }
  # filter {
  #   name   = "tag:Name"
  #   values = ["instance-name-tag"]
  # }
}
