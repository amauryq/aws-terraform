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
  role = "${aws_iam_role.ftp-user.id}"

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
  server_id = "${aws_transfer_server.ftp-server.id}"
  user_name = "${var.ftp_user_name}"
  role      = "${aws_iam_role.ftp-user.arn}"

  tags = {
    NAME = "${var.ftp_user_name}"
  }
}

resource "aws_transfer_ssh_key" "ftp-user" {
  server_id = "${aws_transfer_server.ftp-server.id}"
  user_name = "${aws_transfer_user.ftp-user.user_name}"
  body      = "${var.ftp_user_pubkey}"
}
