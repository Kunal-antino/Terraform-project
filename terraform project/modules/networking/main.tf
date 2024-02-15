data "aws_availability_zone" "available" {}

resource "aws_vpc" "main" {
  cidr_block = "var.main_cidr_block"

  tags = {
    name = "main"
  }
}

resource "aws_subnet" "public_subnet" {
    count = length(var.public_cidr_blocks)
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_cidr_blocks[count.index]
    availability_zone = data.aws_availability_zone.available.name[count.index]
    map_public_ip_on_launch = true

    tags = {
      name = "public_subnet"
    }
}

resource "aws_subnet" "private_subnet" {
    count = length(var.private_cidr_blocks)
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_cidr_blocks[count.index]
    availability_zone = data.aws_availability_zone.available.name[count.index]
    map_public_ip_on_launch = false

    tags = {
      name = "private_subnet"
    }
}

resource "aws_security_group" "front_end_sg" {
    name = "front end sg"
    description = "Allow HTTP to instance"
    vpc_id = aws_vpc.main.id

    ingress {
        description = "allow HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.alb_frontend_sg.id]
    }
    ingress {
        description = "Allow ssh port"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [aws_security_group.alb_frontend_sg.id]
    }
    egress {
        description = "allow all traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "alb_frontend_sg" {
    name = "alb_front_end"
    description = "All traffic to alb"
    vpc_id = aws_vpc.main.id

    ingress {
        description = "allow HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Allow ssh port"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        description = "allow all traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }  
}

resource "aws_security_group" "backend_sg" {
    name = "Back end sg"
    description = "Allow traffic to instance"
    vpc_id = aws_vpc.main.id

    ingress {
        description = "allow HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.alb_backend_sg.id]
    }
    ingress {
        description = "Allow ssh port"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [aws_security_group.alb_backend_sg.id]
    }
    egress {
        description = "allow all traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}

resource "aws_security_group" "alb_backend_sg" {
    name = "alb_back_end"
    description = "All traffic to alb"
    vpc_id = aws_vpc.main.id

    ingress {
        description = "allow HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.front_end_sg.id]
    }
    ingress {
        description = "Allow ssh port"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [aws_security_group.front_end_sg.id]
    }
    egress {
        description = "allow all traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }  
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id

    tags = {
        name = "igw"
    }
}

resource "aws_route_table" "public_route" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "public_route_association" {
  count          = length(var.public_cidr_blocks)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table" "private_route" {
    vpc_id = aws_vpc.main.id
    route  {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.ngw.id
    }
}

resource "aws_route_table_association" "private_route_association" {
    count = length(var.private_cidr_blocks)
    subnet_id = aws_subnet.private_subnet[count.index].id
    route_table_id = aws_route_table.private_route.id
}