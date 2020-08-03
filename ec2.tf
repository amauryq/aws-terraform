# Dev Server

## Key Pair

resource "aws_key_pair" "custom_auth_1" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

## Custom Server

## IAM

resource "aws_iam_role" "custom_iam_role_1" {
  name = "custom_iam_role_1"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "custom_iam_role_policy_1" {
  name = "custom_iam_role_policy_1"
  role = aws_iam_role.custom_iam_role_1.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "custom_instance_profile_1" {
  name = "custom_iam_role_1"
  role = aws_iam_role.custom_iam_role_1.name
}

## EBS Volume

resource "aws_ebs_volume" "custom_ebs_1" {
  type              = "io1"
  size              = 8
  iops              = 100
  availability_zone = "us-east-1a"
  encrypted         = true
  kms_key_id        = var.kms_key_id

  tags = {
    Name = "custom_ebs_1"
  }
}

resource "aws_instance" "custom_instance_1" {
  instance_type           = var.custom_instance_type
  ami                     = var.custom_ami
  key_name                = aws_key_pair.custom_auth_1.id
  vpc_security_group_ids  = [aws_security_group.custom_public_sg_1.id]
  iam_instance_profile    = aws_iam_instance_profile.custom_instance_profile_1.id
  subnet_id               = aws_subnet.custom_public_subnet_1.id
  monitoring              = true
  disable_api_termination = false
  source_dest_check       = true
  hibernation             = false

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 10
    iops                  = 100
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = var.kms_key_id
  }

  # bootstrap script
  # user_data = "${file("bootstrap.sh")}"
  user_data = <<EOF
#!/bin/bash
yum update -y
yum install httpd -y
# yum install amazon-efs-utils -y
yum install git make rpm-build -y
git clone https://github.com/aws/efs-utils
cd efs-utils
make rpm
yum -y install ./build/amazon-efs-utils*rpm
# mount -t efs -o tls ${aws_efs_file_system.custom_efs_1.id}:/ /var/www/html/
echo "<html><h1>Welcome to ${var.domain_name}</h1><h2>Public IP is: $(curl http://169.254.169.254/latest/meta-data/public-ipv4)</h2></html>" > /var/www/html/index.html
service httpd start
chkconfig httpd on
	EOF

  tags = {
    Name = "custom_instance_1"
  }
}

resource "aws_volume_attachment" "custom_volume_attachment_1" {
  device_name  = "/dev/sdb"
  volume_id    = aws_ebs_volume.custom_ebs_1.id
  instance_id  = aws_instance.custom_instance_1.id
  force_detach = true
}

# resource "null_resource" "example_provisioner" {
#   triggers = {
#     public_ip = aws_instance.custom_instance_1.public_ip
#   }

#   connection {
#     type        = "ssh"
#     host        = aws_instance.custom_instance_1.public_ip
#     user        = "ec2-user"
#     password    = ""
#     private_key = file(var.private_key_path)
#   }

#   provisioner "remote-exec" {
#     inline = [
#       # "sudo yum update -y",
#       "sudo yum install httpd -y",
#       # "sudo mv /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/welcome.conf.org",
#       # "sudo chown -R apache:apache /var/www/html/",
#       # "sudo chmod -R 755 /var/www/html/",
#       # "echo '<html><h1>Welcome to ${var.domain_name}</h1><h2>Public IP is: ${aws_instance.custom_instance_1.public_ip}</h2></html>' > index.html",
#       # "sudo mv index.html /var/www/html/index.html",
#       # "sudo chown apache:apache /var/www/html/index.html",
#       # "sudo chmod 755 /var/www/html/index.html",
#       "sudo service httpd start"
#     ]
#   }
# }
