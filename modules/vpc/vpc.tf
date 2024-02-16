resource "aws_vpc" "Cloud-VPC" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
  tags ={
    Name = "AWSCloud-VPC"
  }
}

resource "aws_internet_gateway" "cloudIGW" {
  vpc_id = aws_vpc.Cloud-VPC.id
  tags ={
    Name = "AWSCloud-IGW"
  }
}

resource "aws_eip" "cloudNatGatewayEIP1" {
}

resource "aws_nat_gateway" "cloudNatGateway1" {
  allocation_id = aws_eip.cloudNatGatewayEIP1.id
  subnet_id = aws_subnet.cloudPublicSubnet1.id
  tags ={
    Name = "AWSCloud-NAtGateway1"
  }
}

resource "aws_subnet" "cloudPublicSubnet1" {
  vpc_id = aws_vpc.Cloud-VPC.id
  cidr_block = var.public_subnet_cidrs[0]
  availability_zone = var.availability_zones[0]
  tags ={
    Name = "AWSCloud-PublicSubnet1"
  }
}


resource "aws_eip" "cloudNatGatewayEIP2" {
}

resource "aws_nat_gateway" "cloudNatGateway2" {
  allocation_id = aws_eip.cloudNatGatewayEIP2.id
  subnet_id = aws_subnet.cloudPublicSubnet1.id
  tags ={
    Name = "AWSCloud-NATGateway2"
  }
}

resource "aws_subnet" "cloudPublicSubnet2" {
  vpc_id = aws_vpc.Cloud-VPC.id
  cidr_block = var.public_subnet_cidrs[1]
  availability_zone = var.availability_zones[1]
  tags ={
    Name = "AWSCloud-PublicSubnet2"
  }
}

resource "aws_subnet" "cloudPrivateSubnet1" {
  vpc_id = aws_vpc.Cloud-VPC.id
  cidr_block = var.private_subnet_cidrs[0]
  availability_zone = var.availability_zones[0]
  tags ={
    Name = "AWSCloud-PrivateSubnet1"
  }
}

resource "aws_subnet" "cloudPrivateSubnet2" {
  vpc_id = aws_vpc.Cloud-VPC.id
  cidr_block = var.private_subnet_cidrs[1]
  availability_zone = var.availability_zones[1]
  tags ={
    Name = "AWSCloud-PrivateSubnet2"
  }
}

resource "aws_route_table" "cloudPublicRT" {
  vpc_id = aws_vpc.Cloud-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudIGW.id
  }
  tags = {
    //Name = "cloudPublicRT"
    Name="AWSCloud-PublicRT"
   }
}

resource "aws_route_table" "cloudPrivateRT1" {
  vpc_id = aws_vpc.Cloud-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.cloudNatGateway1.id
  }
  tags = {
    //Name = "cloudPrivateRT1"
    Name="AWSCloud-PrivateRT1"
   }
}

resource "aws_route_table" "cloudPrivateRT2" {
  vpc_id = aws_vpc.Cloud-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.cloudNatGateway2.id
  }
  tags = {
    //Name = "cloudPrivateRT2"
    Name = "AWSCloud-PrivateRT2"

   }
}

resource "aws_route_table_association" "cloudPublicRTassociation1" {
  subnet_id = aws_subnet.cloudPublicSubnet1.id
  route_table_id = aws_route_table.cloudPublicRT.id
}

resource "aws_route_table_association" "cloudPublicRTassociation2" {
  subnet_id = aws_subnet.cloudPublicSubnet2.id
  route_table_id = aws_route_table.cloudPublicRT.id
}

resource "aws_route_table_association" "cloudPrivateRTassociation1" {
  subnet_id = aws_subnet.cloudPrivateSubnet1.id
  route_table_id = aws_route_table.cloudPrivateRT1.id
}

resource "aws_route_table_association" "cloudPrivateRTassociation2" {
  subnet_id = aws_subnet.cloudPrivateSubnet2.id
  route_table_id = aws_route_table.cloudPrivateRT2.id
}

