variable "github_repo" {
  description = "Repositorio que puede asumir el rol (owner/repo)"
  type        = string
  default     = "spulido743/lab-devops"
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

data "aws_iam_policy_document" "confianza_github" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:spulido743@118694265/lab-devops@1432491315:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name                 = "${var.nombre}-github-actions"
  assume_role_policy   = data.aws_iam_policy_document.confianza_github.json
  max_session_duration = 3600
}

data "aws_iam_policy_document" "push_ecr" {
  statement {
    sid       = "TokenDeECR"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
  statement {
    sid = "SubirImagenesSoloAEsteRepo"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeImageScanFindings"
    ]
    resources = [aws_ecr_repository.app.arn]
  }
}

resource "aws_iam_role_policy" "push_ecr" {
  name   = "push-ecr"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.push_ecr.json
}
