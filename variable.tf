variable "aws_region" {}
variable "aws_profile" {}
data "aws_availability_zones" "available" {}
variable "vpc_cidr" {}

variable "cidrs" {
  type = "map"
}

variable "localip" {}
variable "domain_name" {}
variable "db_instance_class" {}
variable "db_instance_name" {}
variable "db_instance_user" {}
variable "db_instance_pass" {}
variable "db_instance_version" {}
