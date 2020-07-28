aws_profile = "it-institute"
aws_region  = "us-east-1"
vpc_cidr    = "10.0.0.0/16"
cidrs = {
  public1  = "10.0.1.0/24"
  public2  = "10.0.2.0/24"
  private1 = "10.0.3.0/24"
  private2 = "10.0.4.0/24"
}
# curl http://canhasip.com
localip     = "76.109.187.235/32"
domain_name = "iteraprocess.net"

key_name             = "amaury.quintero@it-institute-id_rsa"
public_key_path      = "~/.ssh/amaury.quintero@it-institute-id_rsa.pub"
private_key_path     = "~/.ssh/amaury.quintero@it-institute-id_rsa"
custom_instance_type = "t2.micro"
custom_ami           = "ami-098f16afa9edf40be"
