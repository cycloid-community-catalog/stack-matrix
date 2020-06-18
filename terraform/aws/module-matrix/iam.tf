#
# Role
#
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "server" {
  name               = "${var.project}-${var.env}-server"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  path               = "/${var.project}/"
}

resource "aws_iam_instance_profile" "server" {
  name = "${var.project}-${var.env}-profile-server"
  role = aws_iam_role.server.name
}

#
# EC2 tags list
#
data "aws_iam_policy_document" "ec2_tag_describe" {
  statement {
    actions = [
      "ec2:DescribeTags",
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ec2_tag_describe" {
  name        = "${var.project}-${var.env}-ec2-tag-describe"
  path        = "/"
  description = "EC2 tags Read only"
  policy      = data.aws_iam_policy_document.ec2_tag_describe.json
}

resource "aws_iam_role_policy_attachment" "ec2_tag_describe" {
  role       = aws_iam_role.server.name
  policy_arn = aws_iam_policy.ec2_tag_describe.arn
}

#
# CloudFormation stack signal-resource
#
data "aws_iam_policy_document" "cloudformation_signal" {
  statement {
    actions = [
      "cloudformation:SignalResource",
    ]

    effect = "Allow"

    resources = [
      "arn:aws:cloudformation:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stack/${var.project}-${var.env}-server/*",
    ]
  }
}

resource "aws_iam_policy" "cloudformation_signal" {
  name        = "${var.project}-${var.env}-cloudformation-signal"
  path        = "/"
  description = "Allow to send CloudFormation stack signal"
  policy      = data.aws_iam_policy_document.cloudformation_signal.json
}

resource "aws_iam_role_policy_attachment" "cloudformation_signal" {
  role       = aws_iam_role.server.name
  policy_arn = aws_iam_policy.cloudformation_signal.arn
}

#
# Logs
#
data "aws_iam_policy_document" "push_logs" {
  statement {
    effect = "Allow"

    actions = [
      "logs:UntagLogGroup",
      "logs:TagLogGroup",
      "logs:PutRetentionPolicy",
      "logs:PutLogEvents",
      "logs:DeleteRetentionPolicy",
      "logs:CreateLogStream",
    ]

    resources = ["arn:aws:logs:*:*:log-group:${var.project}_${var.env}:*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:ListTagsLogGroup",
      "logs:DescribeSubscriptionFilters",
      "logs:DescribeMetricFilters",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
      "logs:TestMetricFilter",
      "logs:DescribeResourcePolicies",
      "logs:DescribeExportTasks",
      "logs:DescribeDestinations",
      "logs:CreateLogGroup",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "push_logs" {
  name        = "${var.project}-${var.env}-push-logs"
  path        = "/"
  description = "Allow to push logs to CloudWatch"
  policy      = data.aws_iam_policy_document.push_logs.json
}

resource "aws_iam_role_policy_attachment" "push_logs" {
  role       = aws_iam_role.server.name
  policy_arn = aws_iam_policy.push_logs.arn
}
