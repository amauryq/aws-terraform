variable "aws_profile" {
  type    = string
  default = "it-institute"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "kms_key_id" {
  type = string
  default = "arn:aws:kms:us-east-1:347565253946:key/9860c17e-2a93-495d-aaf0-d8fc2f8279dc"
}

data "aws_availability_zones" "available" {}

resource "aws_default_vpc" "default" {
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_default_vpc.default.id
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}

data "aws_subnet" "custom_public_subnet_1" {
  id = aws_default_subnet.default_az1.id
}

data "aws_subnet" "custom_public_subnet_2" {
  id = aws_default_subnet.default_az2.id
}

data "aws_security_group" "custom_public_sg_1" {
  id = aws_default_security_group.default.id
}
