terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

module "networking" {
  source = "./modules/networking "
  region = var.region  
  main_cidr_block = var.main_cidr_block
  public_cidr_blocks = ["10.0.1.0/24, 10.0.2.0/24"]
  private_cidr_blocks = var.private_cidr_blocks

}

module "natgeteway" {
  source = "./modules/natgateway "
  aws_security_group = aws_security_group.alb_back_end
  subnets = aws_subnet.public_subnet
}

module "lb" {
  source = "./modules "
}
