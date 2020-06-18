# Cycloid
variable "customer" {}
variable "project" {}
variable "env" {}

# AWS
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.aws_region
}

variable "access_key" {}

variable "secret_key" {}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-1"
}

# Matrix
variable "rds_password" {
  default = "ChangeMePls"
}
