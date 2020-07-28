provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

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

# Dev Server

## Key Pair

resource "aws_key_pair" "custom_auth_1" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

## Custom Server

resource "aws_instance" "custom_instance_1" {
  instance_type = var.custom_instance_type
  ami           = var.custom_ami

  tags = {
    Name = "custom_instance_1"
  }

  key_name               = aws_key_pair.custom_auth_1.id
  vpc_security_group_ids = [aws_security_group.custom_public_sg_1.id]
  # iam_instance_profile = aws_iam_instance_profile.s3_access_profile.id
  subnet_id = aws_subnet.custom_public_subnet_1.id
}

resource "null_resource" "example_provisioner" {
  triggers = {
    public_ip = aws_instance.custom_instance_1.public_ip
  }

  connection {
    type  = "ssh"
    host  = aws_instance.custom_instance_1.public_ip
    user  = "ec2-user"
    password = ""
    private_key = file(var.private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      # "sudo yum update -y",
      "sudo yum install httpd -y",
      # "sudo mv /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/welcome.conf.org",
      # "sudo chown -R apache:apache /var/www/html/",
      # "sudo chmod -R 755 /var/www/html/",
      # "echo '<html><h1>Welcome to ${var.domain_name}</h1><h2>Public IP is: ${aws_instance.custom_instance_1.public_ip}</h2></html>' > index.html",
      # "sudo mv index.html /var/www/html/index.html",
      # "sudo chown apache:apache /var/www/html/index.html",
      # "sudo chmod 755 /var/www/html/index.html",
      "sudo service httpd start"
    ]
  }
}
