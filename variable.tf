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

variable "elb_healthy_threshold" {}
variable "elb_unhealthy_threshold" {}
variable "elb_timeout" {}
variable "elb_interval" {}

variable "key_name" {}
variable "public_key_path" {}
variable "dev_instance_type" {}
variable "dev_instance_ami" {}
