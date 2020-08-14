provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

resource "aws_cloud9_environment_ec2" "awsbatch-workshop" {
  instance_type = "t2.micro"
  name          = "awsbatch-workshop"
}
