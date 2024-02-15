resource "aws_eip" "nat-ip" {
    count = length(aws_subnet.public_subnet)
    depends_on = [aws_internet_gateway.igw]
    tags = {
      name = "nat-ip"
    }
}

resource "aws_nat_gateway" "ngw" {
    count = length(aws_subnet.public_subnet)
    subnet_id = aws_subnet.public_subnet[count.index].id
    allocation_id = aws_eip.nat-ip[count.index].id
    depends_on = [ aws_internet_gateway.igw ]
    tags = {
        name = "ngw"
    }  
}
