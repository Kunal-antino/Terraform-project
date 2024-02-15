main_cidr_block = "10.0.0.0/16"
public_cidr_blocks = ["10.0.1.0/24, 10.0.2.0/24"]
private_cidr_blocks = ["10.0.3.0/24, 10.0.4.0/24"]
region = "ap-south-1"
aws_security_group = "aws_security_group.alb_backend_sg.id"
subnets = 