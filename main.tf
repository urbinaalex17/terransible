provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

#------- IAM -----------

#S3_access
resource "aws_iam_instance_profile" "s3_access_profile" {
  name = "s3_access"
  role = "${aws_iam_role.s3_access_role.name}"
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name = "s3_access_policy"
  role = "${aws_iam_role.s3_access_role.id}"
  
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "s3_access_role" {
  name = "s3_access_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
    "Action": "sts:AssumeRole",
    "Principal": {
       "Service": "ec2.amazonaws.com"
    },
    "Effect": "Allow",
    "Side": ""
  }
  ]
}
EOF
}


#------- VPC -----------

resource "aws_vpc" "wp_vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags {
    Name= "wp_vpc"
  }
}

resource "aws_internet_gateway" "wp_igw" {
  vpc_id = "${aws_vpc.wp_vpc.id}"
  tags {
    Name= "wp_igw"
  }
}

resource "aws_route_table" "wp_public_rt" {
  vpc_id = "${aws_vpc.wp_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.wp_igw.id}"
  }
  tags {
    Name = "wp_public"
  }
}

resource "aws_default_route_table" "wp_private_rt" {
  default_route_table_id = "${aws_vpc.wp_vpc.default_route_table_id}"
  tags {
    Name = "wp_private"
  }
}

#Subnets

resource "aws_subnet" "wp_public_subnet_01" {
  vpc_id = "${aws_vpc.wp_vpc.id}"
  cidr_block = "${var.cidrs["public_01"]}"
  map_public_ip_on_launch = true
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  
  tags {
    Name = "wp_public_subnet_01"
  }
}


resource "aws_subnet" "wp_public_subnet_02" {
  vpc_id = "${aws_vpc.wp_vpc.id}"
  cidr_block = "${var.cidrs["public_02"]}"
  map_public_ip_on_launch = true
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  
  tags {
    Name = "wp_public_subnet_02"
  }
}


resource "aws_subnet" "wp_private_subnet_03" {
  vpc_id = "${aws_vpc.wp_vpc.id}"
  cidr_block = "${var.cidrs["private_03"]}"
  map_public_ip_on_launch = false
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  
  tags {
    Name = "wp_private_subnet_03"
  }
}


resource "aws_subnet" "wp_private_subnet_04" {
  vpc_id = "${aws_vpc.wp_vpc.id}"
  cidr_block = "${var.cidrs["private_04"]}"
  map_public_ip_on_launch = false
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  
  tags {
    Name = "wp_private_subnet_04"
  }
}


resource "aws_subnet" "wp_rds_subnet_01" {
  vpc_id = "${aws_vpc.wp_vpc.id}"
  cidr_block = "${var.cidrs["rds1"]}"
  map_public_ip_on_launch = false
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  
  tags {
    Name = "wp_rds_subnet_01"
  }
}


resource "aws_subnet" "wp_rds_subnet_02" {
  vpc_id = "${aws_vpc.wp_vpc.id}"
  cidr_block = "${var.cidrs["rds2"]}"
  map_public_ip_on_launch = false
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  
  tags {
    Name = "wp_rds_subnet_02"
  }
}


resource "aws_subnet" "wp_rds_subnet_03" {
  vpc_id = "${aws_vpc.wp_vpc.id}"
  cidr_block = "${var.cidrs["rds3"]}"
  map_public_ip_on_launch = false
  availability_zone = "${data.aws_availability_zones.available.names[2]}"
  
  tags {
    Name = "wp_rds_subnet_03"
  }
}


#RDS Subnet Group

resource "aws_db_subnet_group" "wp_rds_subnetgroup" {
  name = "wp_rds_subnetgroup"
  subnet_ids = ["${aws_subnet.wp_rds_subnet_01.id}",
                "${aws_subnet.wp_rds_subnet_02.id}",
                "${aws_subnet.wp_rds_subnet_03.id}" ]
  tags {
    Name = "wp_rds_sng"
  }
}

#Subnet Associations

resource "aws_route_table_association" "wp_public_01_assoc" {
  subnet_id = "aws_subnet.wp_public_subnet_01.id"
  route_table_id = "aws_route_table.wp_public_rt.id"
}


resource "aws_route_table_association" "wp_public_02_assoc" {
  subnet_id = "aws_subnet.wp_public_subnet_02.id"
  route_table_id = "aws_route_table.wp_public_rt.id"
}


resource "aws_route_table_association" "wp_private_03_assoc" {
  subnet_id = "aws_subnet.wp_private_subnet_03.id"
  route_table_id = "aws_default_route_table.wp_private_rt.id"
}


resource "aws_route_table_association" "wp_private_04_assoc" {
  subnet_id = "aws_subnet.wp_private_subnet_04.id"
  route_table_id = "aws_default_route_table.wp_private_rt.id"
}
