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
    "Sid": ""
  }
  ]
}
EOF
}

#------- VPC -----------

resource "aws_vpc" "wp_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "wp_vpc"
  }
}

resource "aws_internet_gateway" "wp_igw" {
  vpc_id = "${aws_vpc.wp_vpc.id}"

  tags {
    Name = "wp_igw"
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
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["public_01"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "wp_public_subnet_01"
  }
}

resource "aws_subnet" "wp_public_subnet_02" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["public_02"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "wp_public_subnet_02"
  }
}

resource "aws_subnet" "wp_private_subnet_03" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["private_03"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "wp_private_subnet_03"
  }
}

resource "aws_subnet" "wp_private_subnet_04" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["private_04"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "wp_private_subnet_04"
  }
}

resource "aws_subnet" "wp_rds_subnet_01" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["rds1"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "wp_rds_subnet_01"
  }
}

resource "aws_subnet" "wp_rds_subnet_02" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["rds2"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "wp_rds_subnet_02"
  }
}

resource "aws_subnet" "wp_rds_subnet_03" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["rds3"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[2]}"

  tags {
    Name = "wp_rds_subnet_03"
  }
}

#RDS Subnet Group

resource "aws_db_subnet_group" "wp_rds_subnetgroup" {
  name = "wp_rds_subnetgroup"

  subnet_ids = ["${aws_subnet.wp_rds_subnet_01.id}",
    "${aws_subnet.wp_rds_subnet_02.id}",
    "${aws_subnet.wp_rds_subnet_03.id}",
  ]

  tags {
    Name = "wp_rds_sng"
  }
}

#Subnet Associations

resource "aws_route_table_association" "wp_public_01_assoc" {
  subnet_id      = "${aws_subnet.wp_public_subnet_01.id}"
  route_table_id = "${aws_route_table.wp_public_rt.id}"
}

resource "aws_route_table_association" "wp_public_02_assoc" {
  subnet_id      = "${aws_subnet.wp_public_subnet_02.id}"
  route_table_id = "${aws_route_table.wp_public_rt.id}"
}

resource "aws_route_table_association" "wp_private_03_assoc" {
  subnet_id      = "${aws_subnet.wp_private_subnet_03.id}"
  route_table_id = "${aws_default_route_table.wp_private_rt.id}"
}

resource "aws_route_table_association" "wp_private_04_assoc" {
  subnet_id      = "${aws_subnet.wp_private_subnet_04.id}"
  route_table_id = "${aws_default_route_table.wp_private_rt.id}"
}

#Security Groups

#Bastion Host Security Group

resource "aws_security_group" "wp_dev_sg" {
  name        = "wp_dev_sg"
  description = "Used for access to the dev instance"
  vpc_id      = "${aws_vpc.wp_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.localip}"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Public Security Group
resource "aws_security_group" "wp_public_sg" {
  name        = "aws_public_sg"
  description = "Used for the ELB for public access"
  vpc_id      = "${aws_vpc.wp_vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Private Security Group
resource "aws_security_group" "wp_private_sg" {
  name        = "aws_private_sg"
  description = "Used for private instances"
  vpc_id      = "${aws_vpc.wp_vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#RDS Security Group
resource "aws_security_group" "wp_rds_sg" {
  name        = "aws_rds_sg"
  description = "Used for RDS"
  vpc_id      = "${aws_vpc.wp_vpc.id}"

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    security_groups = ["${aws_security_group.wp_public_sg.id}",
      "${aws_security_group.wp_private_sg.id}",
      "${aws_security_group.wp_dev_sg.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#VPC Endpoint for S3

resource "aws_vpc_endpoint" "wp_private-s3_endpoint" {
  vpc_id       = "${aws_vpc.wp_vpc.id}"
  service_name = "com.amazonaws.${var.aws_region}.s3"

  route_table_ids = ["${aws_vpc.wp_vpc.main_route_table_id}",
    "${aws_route_table.wp_public_rt.id}",
  ]

  policy = <<EOF
{
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*",
      "Principal": "*"
    }
  ]
}
EOF
}

#------- S3 CODE BUCKET -----------

resource "random_id" "wp_code_bucket" {
  byte_length = 2
}

resource "aws_s3_bucket" "code" {
  bucket        = "${var.domain_name}-${random_id.wp_code_bucket.dec}"
  acl           = "private"
  force_destroy = true

  tags {
    Name = "Code Bucket"
  }
}

#------- RDS -----------

resource "aws_db_instance" "wp_db" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "${var.db_instance_version}"
  instance_class         = "${var.db_instance_class}"
  name                   = "${var.db_instance_name}"
  username               = "${var.db_instance_user}"
  password               = "${var.db_instance_pass}"
  db_subnet_group_name   = "${aws_db_subnet_group.wp_rds_subnetgroup.name}"
  vpc_security_group_ids = ["${aws_security_group.wp_rds_sg.id}"]
  skip_final_snapshot    = true
}

#------- ELB -----------

resource "aws_elb" "wp_elb" {
  name = "${var.domain_name}-elb"

  subnets = ["${aws_subnet.wp_public_subnet_01.id}",
    "${aws_subnet.wp_public_subnet_02.id}",
  ]

  security_groups = ["${aws_security_group.wp_public_sg.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = "${var.elb_healthy_threshold}"
    unhealthy_threshold = "${var.elb_unhealthy_threshold}"
    timeout             = "${var.elb_timeout}"
    target              = "TCP:80"
    interval            = "${var.elb_interval}"
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "wp_${var.domain_name}-elb"
  }
}

#------- DEV INSTANCE -----------

# Key Pair

resource "aws_key_pair" "wp_auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

# Dev Server

resource "aws_instance" "wp_ec2_dev" {
  instance_type = "${var.dev_instance_type}"
  ami           = "${var.dev_instance_ami}"

  tags {
    Name = "wp_dev"
  }

  key_name               = "${aws_key_pair.wp_auth.id}"
  vpc_security_group_ids = ["${aws_security_group.wp_dev_sg.id}"]
  iam_instance_profile   = "${aws_iam_instance_profile.s3_access_profile.id}"
  subnet_id              = "${aws_subnet.wp_public_subnet_01.id}"

  provisioner "local-exec" {
    command = <<EOD
cat <<EOF > aws_hosts
[dev]
${aws_instance.wp_ec2_dev.public_ip}
[dev:vars]
s3code=${aws_s3_bucket.code.bucket}
domain=${var.domain_name}
EOF
EOD
  }

  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.wp_ec2_dev.id} --profile ${var.aws_profile} && ansible-playbook -i aws_hosts wordpress.yml"
  }
}

#------- GOLDEN AMI -----------

resource "random_id" "golden_ami" {
  byte_length = 3
}

resource "aws_ami_from_instance" "aws_golden_ami" {
  name               = "wp-ami-${random_id.golden_ami.b64}"
  source_instance_id = "${aws_instance.wp_ec2_dev.id}"

  provisioner "local-exec" {
    command = <<EOT
cat <<EOF > userdata
#!/bin/bash
/usr/bin/aws s3 sync s3://${aws_s3_bucket.code.bucket} /var/www/html/
/bin/touch /var/spool/cron/root
sudo /bin/echo '*/5 * * * * aws s3 sync s3://${aws_s3_bucket.code.bucket} /var/www/html' >> /var/spool/cron/root
EOF
EOT
  }
}



#------- LAUNCH  CONFIGURATION -----------

resource "aws_launch_configuration" "wp_asg_lc" {
  name_prefix = "wp_lc-"
  image_id = "${aws_ami_from_instance.aws_golden_ami.id}"
  instance_type = "${var.lb_instance_type}"
  security_groups = ["${aws_security_group.wp_private_sg.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.s3_access_profile.id}"
  key_name = "${aws_key_pair.wp_auth.id}"
  user_data = "${file("userdata")}"

  lifecycle {
    create_before_destroy = true
  }
}


#------- ASG -----------

resource "aws_autoscaling_group" "wp_asg" {
  name = "asg-${aws_launch_configuration.wp_asg_lc.id}"
  max_size = "${var.asg_max}"
  min_size = "${var.asg_min}"
  health_check_grace_period = "${var.asg_grace}"
  health_check_type = "${var.asg_hct}"
  desired_capacity = "${var.asg_cap}"
  force_delete = true
  load_balancers = ["${aws_elb.wp_elb.id}"]
  
  vpc_zone_identifier = ["${aws_subnet.wp_private_subnet_03.id}",
                         "${aws_subnet.wp_private_subnet_04.id}"]
  launch_configuration = "${aws_launch_configuration.wp_asg_lc.name}"
  tags {
    key = "Name"
    value = "wp_asg-instance"
    propagate_at_launch = true
  }
  
  lifecycle {
    create_before_destroy = true
  }
}
