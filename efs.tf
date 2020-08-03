resource "aws_efs_file_system" "custom_efs_1" {
  creation_token   = "custom_token_1"
  encrypted        = true
  kms_key_id       = var.kms_key_id
  performance_mode = "generalPurpose"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "custom_efs_1"
  }
}

resource "aws_efs_file_system_policy" "custom_efs_policy_1" {
  file_system_id = aws_efs_file_system.custom_efs_1.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "custom_efs_policy_1",
    "Statement": [
        {
            "Sid": "custom_efs_statement_1",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Resource": "${aws_efs_file_system.custom_efs_1.arn}",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientRootAccess",
                "elasticfilesystem:ClientWrite"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "true"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_efs_mount_target" "custom_efs_mount_target_1" {
  file_system_id  = aws_efs_file_system.custom_efs_1.id
  subnet_id       = aws_subnet.custom_public_subnet_1.id
  security_groups = [aws_security_group.custom_public_sg_1.id]
}

resource "aws_efs_mount_target" "custom_efs_mount_target_2" {
  file_system_id  = aws_efs_file_system.custom_efs_1.id
  subnet_id       = aws_subnet.custom_public_subnet_2.id
  security_groups = [aws_security_group.custom_public_sg_1.id]
}
