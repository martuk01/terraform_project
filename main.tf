data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] 
}

resource "aws_vpc" "project-vpc"{
    cidr_block = var.vpc_cidr
    
    tags ={
        name = "project-vpc"
    }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.project-vpc.id

  tags = local.tags
}

resource "aws_subnet" "private_subnet" {
    vpc_id     = aws_vps.project-vps.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "${local.region}a"
    tags ={
        name = "private-subnet"
    }
}

resource "aws_subnet" "public_subnet" {
   vpc_id     = aws_vps.project-vps.id 
   cidr_block = "10.0.2.0/24"
   availability_zone = "${local.region}b"
   tags ={
        name = "public-subnet"
    }
}

resource "aws_route_table" "route" {
    vpc_id = aws_vpc.project-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = local.tags
}

 resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route.id
} 

  resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = local.tags

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "route" {
    vpc_id = aws_vpc.project-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = local.tags
}

 resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.route.id
} 

  resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.private_subnet.id

  tags = local.tags

  depends_on = [aws_internet_gateway.gw]
}