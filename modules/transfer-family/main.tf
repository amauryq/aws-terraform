provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

# server

resource "aws_iam_role" "ftp-server" {
  name = "tf-test-transfer-server-iam-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "ftp-server" {
  name = "tf-test-transfer-server-iam-policy"
  role = aws_iam_role.ftp-server.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "AllowFullAccesstoCloudWatchLogs",
        "Effect": "Allow",
        "Action": [
            "logs:*"
        ],
        "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_transfer_server" "ftp-server" {
  identity_provider_type = "SERVICE_MANAGED"
  logging_role           = aws_iam_role.ftp-server.arn

  tags = {
    NAME = var.ftp_server_name
    ENV  = var.env
  }
}

# user

resource "aws_iam_role" "ftp-user" {
  name = "tf-test-transfer-user-iam-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "ftp-user" {
  name = "tf-test-transfer-user-iam-policy"
  role = aws_iam_role.ftp-user.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowFullAccesstoS3",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_transfer_user" "ftp-user" {
  server_id = aws_transfer_server.ftp-server.id
  user_name = var.ftp_user_name
  role      = aws_iam_role.ftp-user.arn

  tags = {
    NAME = var.ftp_user_name
  }
}

resource "aws_transfer_ssh_key" "ftp-user" {
  server_id = aws_transfer_server.ftp-server.id
  user_name = aws_transfer_user.ftp-user.user_name
  body      = file(var.ftp_user_pubkey)
}
