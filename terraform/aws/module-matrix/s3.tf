#
# S3 Bucket medias
#

# data "aws_iam_policy_document" "s3_bucket_public_medias" {
#   count = var.create_s3_medias ? 1 : 0

#   statement {
#     sid = "PublicReadAccess"

#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }

#     effect = "Allow"

#     actions = [
#       "s3:GetObject",
#     ]

#     resources = [
#       "arn:aws:s3:::${var.customer}-${var.project}-${var.env}-medias/*",
#     ]
#   }
# }

resource "aws_s3_bucket" "medias" {
  count = var.create_s3_medias ? 1 : 0

  bucket = "${var.customer}-${var.project}-${var.env}-medias"
  # policy = var.s3_medias_policy_json != "" ? var.s3_medias_policy_json : data.aws_iam_policy_document.s3_bucket_public_medias[0].json
  acl    = var.s3_medias_acl

  tags = merge(local.merged_tags, {
    Name = "${var.customer}-${var.project}-${var.env}-medias"
    role = "medias"
  })

}

#
# IAM
#

data "aws_iam_policy_document" "s3_medias" {
  count = var.create_s3_medias ? 1 : 0

  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
    ]

    effect = "Allow"

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    actions = [
      "s3:*",
    ]

    effect = "Allow"

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.medias[0].id}",
    ]
  }

  statement {
    actions = [
      "s3:*",
    ]

    effect = "Allow"

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.medias[0].id}/*",
    ]
  }
}

resource "aws_iam_policy" "s3_medias" {
  count       = var.create_s3_medias ? 1 : 0
  name        = "${var.project}-${var.env}-s3-medias-access"
  description = "Grant S3 medias access on bucket ${aws_s3_bucket.medias[0].id}"
  policy      = data.aws_iam_policy_document.s3_medias[0].json
}

resource "aws_iam_user" "s3_medias" {
  count = var.create_s3_medias ? 1 : 0
  name  = "${var.project}-${var.env}-s3-medias"
  path  = "/${var.project}/"
}

resource "aws_iam_access_key" "s3_medias" {
  count = var.create_s3_medias ? 1 : 0
  user  = aws_iam_user.s3_medias[0].name
}

resource "aws_iam_user_policy_attachment" "s3_medias_access" {
  count      = var.create_s3_medias ? 1 : 0
  user       = aws_iam_user.s3_medias[0].name
  policy_arn = aws_iam_policy.s3_medias[0].arn
}

resource "aws_iam_role_policy_attachment" "server_medias_access" {
  count      = var.create_s3_medias ? 1 : 0
  role       = aws_iam_role.server.name
  policy_arn = aws_iam_policy.s3_medias[0].arn
}
