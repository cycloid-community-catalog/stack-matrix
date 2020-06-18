# Cycloid
variable "project" {}
variable "env" {}
variable "customer" {}

# AWS
data "aws_caller_identity" "current" {
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

# Example ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
variable "zones" {
  description = "To use specific AWS Availability Zones."
  default     = []
}

locals {
  aws_availability_zones = length(var.zones) > 0 ? var.zones : data.aws_availability_zones.available.names
}

variable "keypair_name" {
  default = "cycloid"
}

variable "extra_tags" {
  default = {}
}

locals {
  standard_tags = {
    "cycloid.io" = "true"
    env          = var.env
    project      = var.project
    client       = var.customer
  }
  merged_tags = merge(local.standard_tags, var.extra_tags)
}

# DNS
variable "create_route53_records" {
  default = false
}

variable "route53_zone_id" {
  default = ""
}

# Network
variable "vpc_id" {
}

variable "bastion_sg_allow" {
}

variable "metrics_sg_allow" {
  default = ""
}

variable "private_subnets_ids" {
  type = list(string)
}

variable "public_subnets_ids" {
  type = list(string)
}

# S3 medias
variable "create_s3_medias" {
  default = true
}

variable "s3_medias_acl" {
  default = "private"
}

variable "s3_medias_policy_json" {
  default = ""
}

# RDS
variable "create_rds" {
  default = true
}
variable "rds_type" {
  default = "db.t3.small"
}

variable "rds_storage_type" {
  default = "gp2"
}

variable "rds_disk_size" {
  default = 10
}

variable "rds_multiaz" {
  default = false
}

variable "rds_engine_version" {
  default = "12.2"
}

variable "rds_parameters" {
  default = "default.postgres12"
}

variable "rds_username" {
  default = "matrix"
}

variable "rds_password" {
  default = "ChangeMePls"
}

variable "rds_database" {
  default = "matrix"
}

variable "rds_backup_retention" {
  default = 7
}

variable "rds_skip_final_snapshot" {
  default = true
}

variable "rds_subnet_group" {
  default = ""
}

variable "rds_extra_sg_allow" {
  default = ""
}

# Server
variable "server_type" {
  default = "t3.small"
}

variable "debian_ami_name" {
  default = "debian-stretch-*"
}

variable "server_disk_type" {
  default = "gp2"
}

variable "server_disk_size" {
  default = 30
}

variable "server_ebs_optimized" {
  default = false
}

variable "server_associate_public_ip_address" {
  default = true
}

# SES
variable "create_ses_access" {
  default = false
}

variable "ses_resource_arn" {
  default = "*"
}

# matrix discovery
variable "create_external_alb_discovery_listener_rule" {
  default = false
}

variable "external_alb_discovery_listener_arn" {
  default = ""
}

variable "external_alb_health_check_path" {
  default = "/"
}

variable "external_alb_health_check_matcher" {
  default = 200
}

variable "external_alb_health_check_timeout" {
  default = 15
}

variable "external_alb_health_check_interval" {
  default = 45
}

# Others
variable "default_short_name" {
  default = ""
}

resource "random_string" "id" {
  length  = 18
  upper   = false
  special = false
}

#local.default_short_name is lenght 20
locals {
  default_short_name     = var.default_short_name != "" ? var.default_short_name : "cy${random_string.id.result}"
}

#Used to only keep few char for component like ALB name
variable "nameregex" {
  default = "/[^0-9A-Za-z-]/"
  type    = string
}
