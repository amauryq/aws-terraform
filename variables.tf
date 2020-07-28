variable "aws_profile" {}
variable "aws_region" {}
data "aws_availability_zones" "available" {}
variable "vpc_cidr" {}
variable "cidrs" {
  type = map
}

variable "localip" {}
variable "domain_name" {}

variable "key_name" {}
variable "public_key_path" {}
variable "private_key_path" {}

variable "custom_instance_type" {}
variable "custom_ami" {}
