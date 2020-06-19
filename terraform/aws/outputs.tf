#
# Server
#
output "server_public_ip" {
  value       = module.matrix.server_public_ip
  description = "The server public IP."
}

output "server_public_dns" {
  value       = module.matrix.server_public_dns
  description = "The server public DNS."
}

output "server_private_ip" {
  value       = module.matrix.server_private_ip
  description = "The server private IP."
}

output "server_private_dns" {
  value       = module.matrix.server_private_dns
  description = "The server private DNS."
}

#
# RDS
#
output "rds_address" {
  value       = module.matrix.rds_address
  description = "Address of the RDS database."
}

output "rds_port" {
  value       = module.matrix.rds_port
  description = "Port of the RDS database."
}

output "rds_username" {
  value       = module.matrix.rds_username
  description = "Username of the RDS database."
}

#
# S3 Bucket medias
#
output "s3_medias_bucket_name" {
  value = module.matrix.s3_medias_bucket_name
}

output "s3_medias_iam_user_access_key" {
  value = module.matrix.s3_medias_iam_user_access_key
}

output "s3_medias_iam_user_secret_key" {
  value = module.matrix.s3_medias_iam_user_secret_key
}

#
# SES
#
output "ses_iam_user_access_key" {
  value = module.matrix.ses_iam_user_access_key
}

output "ses_iam_user_secret_key" {
  value = module.matrix.ses_iam_user_secret_key
}

output "ses_iam_user_smtp_password" {
  value = module.matrix.ses_iam_user_smtp_password
}