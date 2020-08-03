#----- VPC -----

resource "aws_vpc" "custom_vpc_1" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "custom_vpc_1"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "custom_ig_1" {
  vpc_id = aws_vpc.custom_vpc_1.id

  tags = {
    Name = "custom_ig_1"
  }
}

# Route Tables

resource "aws_route_table" "custom_public_rt_1" {
  vpc_id = aws_vpc.custom_vpc_1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custom_ig_1.id
  }

  tags = {
    Name = "custom_public_rt_1"
  }
}

resource "aws_default_route_table" "custom_private_rt_1" {
  default_route_table_id = aws_vpc.custom_vpc_1.default_route_table_id

  tags = {
    Name = "custom_private_rt_1"
  }
}

# Subnets

resource "aws_subnet" "custom_public_subnet_1" {
  vpc_id                  = aws_vpc.custom_vpc_1.id
  cidr_block              = var.cidrs["public1"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "custom_public_subnet_1"
  }
}

resource "aws_subnet" "custom_public_subnet_2" {
  vpc_id                  = aws_vpc.custom_vpc_1.id
  cidr_block              = var.cidrs["public2"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "custom_public_subnet_2"
  }
}

resource "aws_subnet" "custom_private_subnet_1" {
  vpc_id                  = aws_vpc.custom_vpc_1.id
  cidr_block              = var.cidrs["private1"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "custom_private_subnet_1"
  }
}

resource "aws_subnet" "custom_private_subnet_2" {
  vpc_id                  = aws_vpc.custom_vpc_1.id
  cidr_block              = var.cidrs["private2"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "custom_private_subnet_2"
  }
}

# Subnet Associations

resource "aws_route_table_association" "custom_public_assoc_1" {
  subnet_id      = aws_subnet.custom_public_subnet_1.id
  route_table_id = aws_route_table.custom_public_rt_1.id
}

resource "aws_route_table_association" "custom_public_assoc_2" {
  subnet_id      = aws_subnet.custom_public_subnet_2.id
  route_table_id = aws_route_table.custom_public_rt_1.id
}

resource "aws_route_table_association" "custom_private_assoc_1" {
  subnet_id      = aws_subnet.custom_private_subnet_1.id
  route_table_id = aws_default_route_table.custom_private_rt_1.id
}

resource "aws_route_table_association" "custom_private_assoc_2" {
  subnet_id      = aws_subnet.custom_private_subnet_2.id
  route_table_id = aws_default_route_table.custom_private_rt_1.id
}

# Security Groups

## Public SG

resource "aws_security_group" "custom_public_sg_1" {
  name        = "custom_public_sg_1"
  description = "Used for ELB or public access"
  vpc_id      = aws_vpc.custom_vpc_1.id
  # ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.localip]
  }
  # http
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # NFS
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ActiveMQ Console
  ingress {
    from_port   = 8162
    to_port     = 8162
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # OpenWire
  ingress {
    from_port   = 61617
    to_port     = 61617
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # AMQP
  ingress {
    from_port   = 5671
    to_port     = 5671
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## Private SG

resource "aws_security_group" "custom_private_sg_1" {
  name        = "custom_private_sg_1"
  description = "Used for private instances"
  vpc_id      = aws_vpc.custom_vpc_1.id
  # Access from VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
