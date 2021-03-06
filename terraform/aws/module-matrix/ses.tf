#
# IAM
#

data "aws_iam_policy_document" "ses" {
  count = var.create_ses_access ? 1 : 0

  statement {
    actions = [
      "ses:ListIdentities",
      "ses:SendEmail",
      "ses:SendRawEmail",
    ]

    effect = "Allow"

    resources = [
      "${var.ses_resource_arn}",
    ]
  }
}

resource "aws_iam_policy" "ses" {
  count       = var.create_ses_access ? 1 : 0
  name        = "${var.project}-${var.env}-ses-access"
  description = "Grant SES access on ${var.ses_resource_arn}"
  policy      = data.aws_iam_policy_document.ses[0].json
}

resource "aws_iam_user" "ses" {
  count = var.create_ses_access ? 1 : 0
  name  = "${var.project}-${var.env}-ses"
  path  = "/${var.project}/"
}

resource "aws_iam_access_key" "ses" {
  count = var.create_ses_access ? 1 : 0
  user  = aws_iam_user.ses[0].name
}

resource "aws_iam_user_policy_attachment" "ses_access" {
  count      = var.create_ses_access ? 1 : 0
  user       = aws_iam_user.ses[0].name
  policy_arn = aws_iam_policy.ses[0].arn
}

# Allow the server to send email directly
resource "aws_iam_role_policy_attachment" "ses_access" {
  count      = var.create_ses_access ? 1 : 0
  role       = aws_iam_role.server.name
  policy_arn = aws_iam_policy.ses[0].arn
}
