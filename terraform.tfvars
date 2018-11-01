aws_profile = "aws_admin"
aws_region = "us-east-1"
vpc_cidr = "10.17.0.0/16"
cidrs = {
  public_01  = "10.17.1.0/24"
  public_02  = "10.17.2.0/24"
  private_03 = "10.17.3.0/24"
  private_04 = "10.17.4.0/24"
  rds1       = "10.17.11.0/24"
  rds2       = "10.17.12.0/24"
  rds3       = "10.17.13.0/24"
}
localip = "52.53.157.247/32" 
domain_name = "urbinaalex"
db_instance_class = "db.t2.micro"
db_instance_name = "wp-rds-db"
db_instance_user = "urbinaalex"
db_instance_pass = "urbinaalex_pass"
db_instance_version = "8.0.11"

elb_healthy_threshold = "2"
elb_unhealthy_threshold = "2"
elb_timeout = "3"
elb_interval = "30"


key_name = "AWS-TA-KEYPAIR"
public_key_path = "/root/.ssh/triplet.pub"
dev_instance_type = "t2.micro"
dev_instance_ami = "ami-b73b63a0"

lb_instance_type = "t2.micro"
asg_max = "2"
asg_min = "1"
asg_grace = "300"
asg_hct = "EC2"
asg_cap = "2"


