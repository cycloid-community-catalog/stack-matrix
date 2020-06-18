#
# Server
#
output "server_public_ip" {
  value = aws_eip.server.public_ip
}

output "server_public_dns" {
  value = aws_eip.server.public_dns
}

output "server_private_ip" {
  value = aws_eip.server.private_ip
}

output "server_private_dns" {
  value = aws_eip.server.private_dns
}

#
# RDS
#
output "rds_address" {
  value = join("", aws_db_instance.postgresql_database.*.address)
}

output "rds_port" {
  value = join("", aws_db_instance.postgresql_database.*.port)
}

output "rds_database" {
  value = join("", aws_db_instance.postgresql_database.*.name)
}

output "rds_username" {
  value = join("", aws_db_instance.postgresql_database.*.username)
}

#
# S3 Bucket medias
#
output "s3_medias_bucket_name" {
  value = join("", aws_s3_bucket.medias.*.id)
}

output "s3_medias_iam_user_access_key" {
  value = join("", aws_iam_access_key.s3_medias.*.id)
}

output "s3_medias_iam_user_secret_key" {
  value = join("", aws_iam_access_key.s3_medias.*.secret)
}

#
# SES
#
output "ses_iam_user_access_key" {
  value = join("", aws_iam_access_key.ses.*.id)
}

output "ses_iam_user_secret_key" {
  value = join("", aws_iam_access_key.ses.*.secret)
}

output "ses_iam_user_smtp_password" {
  value = join("", aws_iam_access_key.ses.*.ses_smtp_password_v4)
}
