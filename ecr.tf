resource "aws_ecr_repository" "custom_ecr_repo_1" {
  count = var.use_ecr

  name                 = "custom_ecr_repo_1"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "custom_ecr_repo_1"
  }
}

resource "aws_ecr_repository_policy" "custom_ecr_repo_policy_1" {
  count = var.use_ecr

  repository = aws_ecr_repository.custom_ecr_repo_1[count.index].name

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "custom_ecr_repo_policy_1",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy"
            ]
        }
    ]
}
EOF
}

resource "aws_ecr_lifecycle_policy" "custom_ecr_lifecycle_policy_1" {
  count = var.use_ecr

  repository = aws_ecr_repository.custom_ecr_repo_1[count.index].name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
