variable "use_vpc" {}
variable "use_ec2" {}
variable "use_efs" {}
variable "use_ecr" {}
variable "use_mq" {}

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

variable "kms_key_id" {}


variable k8s_role_names {}
variable k8s_group_names {}
variable k8s_user_names {}
