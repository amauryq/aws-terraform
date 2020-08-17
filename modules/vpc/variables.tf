variable "aws_profile" {
  type    = string
  default = "it-institute"
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

data "aws_availability_zones" "available" {}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "cidrs" {
  type = map(string)
  default = {
    public1  = "10.0.1.0/24"
    public2  = "10.0.2.0/24"
    private1 = "10.0.3.0/24"
    private2 = "10.0.4.0/24"
  }
}

variable "localip" {
  type = string
  # curl http://canhasip.com
  # default = "76.109.187.235/32"
  default = "73.192.54.91/32"
}
