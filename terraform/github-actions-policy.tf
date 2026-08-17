resource "aws_iam_policy" "github_actions" {

  name = "GitHubActionsDeployPolicy"

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Action = [
          "eks:*",
          "ec2:*",
          "elasticloadbalancing:*",
          "autoscaling:*",
          "ecr:*",
          "s3:*",
          "iam:PassRole"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_attach" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}