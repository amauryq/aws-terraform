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
