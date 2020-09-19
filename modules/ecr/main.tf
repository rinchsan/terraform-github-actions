locals {
  name = "${var.env}-${var.name}"
}

resource "aws_ecr_repository" "ecr" {
  name = local.name

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Terraform   = true
    Environment = var.env
    Name        = local.name
  }
}

## ref: https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html
resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  repository = aws_ecr_repository.ecr.name

  policy = jsonencode(
    {
      rules = [
        {
          rulePriority = 1
          description  = "keep last 30 prd images"
          selection = {
            tagStatus     = "tagged"
            tagPrefixList = ["prd-"]
            countType     = "imageCountMoreThan"
            countNumber   = 30
          }
          action = {
            type = "expire"
          }
        },
        {
          rulePriority = 5
          description  = "keep last 10 dev images"
          selection = {
            tagStatus     = "tagged"
            tagPrefixList = ["dev-"]
            countType     = "imageCountMoreThan"
            countNumber   = 10
          }
          action = {
            type = "expire"
          }
        },
        {
          rulePriority = 10
          description  = "keep last 10 untagged images"
          selection = {
            tagStatus   = "untagged"
            countType   = "imageCountMoreThan"
            countNumber = 10
          }
          action = {
            type = "expire"
          }
        },
        {
          rulePriority = 15
          description  = "keep last 10 unknown-tagged images"
          selection = {
            tagStatus   = "any"
            countType   = "imageCountMoreThan"
            countNumber = 10
          }
          action = {
            type = "expire"
          }
        },
      ]
    }
  )
}
