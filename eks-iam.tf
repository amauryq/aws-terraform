data "aws_caller_identity" "current" {}

# IAM Roles

resource "aws_iam_role" "k8s_roles" {
  count       = length(var.k8s_role_names)
  name        = var.k8s_role_names[count.index]
  description = var.k8s_role_descriptions[count.index]

  assume_role_policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Principal":{
        "AWS":"arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action":"sts:AssumeRole",
      "Condition":{
        "Bool": {
          "aws:SecureTransport": "true"
        }
      }
    }
  ]
}
POLICY

  tags = {
    service = "k8s"
  }
}

# IAM Groups

resource "aws_iam_group" "k8s_groups" {
  count = length(var.k8s_group_names)
  name  = var.k8s_group_names[count.index]
  path  = "/"
}

# IAM Groups Policies

resource "aws_iam_group_policy" "k8s_group_policy" {
  count = length(aws_iam_group.k8s_groups)
  name  = aws_iam_group.k8s_groups[count.index].name
  group = aws_iam_group.k8s_groups[count.index].id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAssumeOrganizationAccountRole",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_group.k8s_groups[count.index].name}"
    }
  ]
}
POLICY
}

# IAM Users

resource "aws_iam_user" "k8s_users" {
  count = length(var.k8s_user_names)
  name  = var.k8s_user_names[count.index]
}

resource "aws_iam_user_group_membership" "k8s_group_membership" {
  count = length(aws_iam_user.k8s_users)
  user  = aws_iam_user.k8s_users[count.index].name

  groups = [
    aws_iam_group.k8s_groups[count.index].name
  ]
}

# IAM Users Access Key

resource "aws_iam_access_key" "k8s_users_access_key" {
  count = length(aws_iam_user.k8s_users)
  user  = aws_iam_user.k8s_users[count.index].name
}

output "secret" {
  value = [
    aws_iam_access_key.k8s_users_access_key[0].id,
    aws_iam_access_key.k8s_users_access_key[0].secret,
    aws_iam_access_key.k8s_users_access_key[1].id,
    aws_iam_access_key.k8s_users_access_key[1].secret,
    aws_iam_access_key.k8s_users_access_key[2].id,
    aws_iam_access_key.k8s_users_access_key[2].secret
  ]
}
