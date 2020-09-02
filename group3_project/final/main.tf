provider "aws" {
  region     = var.aws_region
  profile    = var.aws_profile
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "template" {
    version = "~> 2.1.2"
}
# # Route53
# resource "aws_route53_zone" "primary" {
#   name = "gurkancloud.com"
# }


# resource "aws_route53_record" "www" {
#   zone_id = "aws_route53_zone.primary.zone_id"
#   name    = "gurkancloud.com"
#   type    = "A"
#   ttl     = "300"
#   records = ["aws_eip.group3_web_elb.public_ip"]
  # alias = {
  #   name                   = "d130easdflja734js.cloudfront.net"
  #   zone_id                = "Z2FDRFHATA1ER4"
  #   evaluate_target_health = false
  # }
# }




#--- VPC ---


resource "aws_vpc" "group3_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "group3_vpc"
  }

}

# Internet Gateway
resource "aws_internet_gateway" "group3_internet_gateway" {
  vpc_id = aws_vpc.group3_vpc.id

  tags = {
    Name = "group3_igw"
  }
}

# Nat Gateway
resource "aws_eip" "group3_eip" {
  
}
resource "aws_nat_gateway" "group3_nat" {
  allocation_id = aws_eip.group3_eip.id
  subnet_id     = aws_subnet.group3_public2_subnet.id
  tags = {
    Name = "group3_nat"
  }
}
# Route tables
resource "aws_route_table" "group3_public_rt" {
  vpc_id = aws_vpc.group3_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.group3_internet_gateway.id
  }
  tags = {
    Name = "group3_public"
  }
}

resource "aws_default_route_table" "group3_private1_rt" {
  default_route_table_id = aws_vpc.group3_vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.group3_nat.id
  }
  tags = {
    Name = "group3_private1"
  }
}
# resource "aws_default_route_table" "group3_private2_rt" {
#   default_route_table_id = aws_vpc.group3_vpc.default_route_table_id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_nat_gateway.group3_nat.id
#   }
#   tags = {
#     Name = "group3_private2"
#   }
# }
# resource "aws_default_route_table" "group3_rds_rt" {
#   default_route_table_id = aws_vpc.group3_vpc.default_route_table_id
#   route {
#     cidr_block = "0.0.0.0/0"
#   }
#   tags = {
#     Name = "group3_rds"
#   }
# }

# Subnets

resource "aws_subnet" "group3_public1_subnet" {
  vpc_id                  = aws_vpc.group3_vpc.id
  cidr_block              = var.cidrs["public1"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "group3_public1"
  }
}
resource "aws_subnet" "group3_public2_subnet" {
  vpc_id                  = aws_vpc.group3_vpc.id
  cidr_block              = var.cidrs["public2"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "group3_public2"
  }
}


resource "aws_subnet" "group3_private1_subnet" {
  vpc_id                  = aws_vpc.group3_vpc.id
  cidr_block              = var.cidrs["private1"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "group3_private1"
  }
}

resource "aws_subnet" "group3_private2_subnet" {
  vpc_id                  = aws_vpc.group3_vpc.id
  cidr_block              = var.cidrs["private2"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "group3_private2"
  }
}
resource "aws_subnet" "group3_private3_subnet" {
  vpc_id                  = aws_vpc.group3_vpc.id
  cidr_block              = var.cidrs["private3"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "group3_private3"
  }
}

resource "aws_subnet" "group3_private4_subnet" {
  vpc_id                  = aws_vpc.group3_vpc.id
  cidr_block              = var.cidrs["private4"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "group3_private4"
  }
}
resource "aws_subnet" "group3_rds1_subnet" {
  vpc_id                  = aws_vpc.group3_vpc.id
  cidr_block              = var.cidrs["rds1"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "group3_rds1"
  }
}
resource "aws_subnet" "group3_rds2_subnet" {
  vpc_id                  = aws_vpc.group3_vpc.id
  cidr_block              = var.cidrs["rds2"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "group3_rds2"
  }
}

#Rds Subnet group
resource "aws_db_subnet_group" "group3_rds_subnetgroup" {
  name = "group3_rds_subnetgroup"

  subnet_ids = [aws_subnet.group3_rds1_subnet.id,
  aws_subnet.group3_rds2_subnet.id]

  tags = {
    name = "group3_rds_subgrp"
  }
}

#Subnet associations
resource "aws_route_table_association" "group3_public1_assoc" {
  subnet_id      = aws_subnet.group3_public1_subnet.id
  route_table_id = aws_route_table.group3_public_rt.id
}

resource "aws_route_table_association" "group3_public2_assoc" {
  subnet_id      = aws_subnet.group3_public2_subnet.id
  route_table_id = aws_route_table.group3_public_rt.id
}

resource "aws_route_table_association" "group3_private1_assoc" {
  subnet_id      = aws_subnet.group3_private1_subnet.id
  route_table_id = aws_default_route_table.group3_private1_rt.id
}

resource "aws_route_table_association" "group3_private2_assoc" {
  subnet_id      = aws_subnet.group3_private2_subnet.id
  route_table_id = aws_default_route_table.group3_private1_rt.id
}
resource "aws_route_table_association" "group3_private3_assoc" {
  subnet_id      = aws_subnet.group3_private3_subnet.id
  route_table_id = aws_default_route_table.group3_private1_rt.id
}

resource "aws_route_table_association" "group3_private4_assoc" {
  subnet_id      = aws_subnet.group3_private4_subnet.id
  route_table_id = aws_default_route_table.group3_private1_rt.id
}

# NACL
resource "aws_network_acl" "allowall" {
  vpc_id = aws_vpc.group3_vpc.id
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  ingress {
    protocol   = "-1" #means allowing all protocols
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}



#--- Security Groups

#Public
resource "aws_security_group" "group3_web_sg" {
  name        = "group3_web_sg"
  description = "Used by ELB for public access to web servers"
  vpc_id      = aws_vpc.group3_vpc.id

  #http from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    
  }
  #ssh
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.vpc_cidr]
  }
  
  
  # For the sake of this exercise, allow all traffic out
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
}

#Private
resource "aws_security_group" "group3_app_sg" {
  name        = "group3_app_sg"
  description = "Used for frontend to backend comms"
  vpc_id      = aws_vpc.group3_vpc.id

  #HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
}

#RDS Security Group
resource "aws_security_group" "group3_rds_sg" {
  name        = "group3_rds_sg"
  description = "Used for RDS instances"
  vpc_id      = aws_vpc.group3_vpc.id

  #SQL access from public and private SGs
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.group3_web_sg.id, aws_security_group.group3_app_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
}


#--- ELB ---

resource "aws_elb" "group3_web_elb" {
  name = "group3-web-elb"

  subnets = [aws_subnet.group3_private1_subnet.id,
  aws_subnet.group3_private2_subnet.id]
  security_groups = [aws_security_group.group3_web_sg.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  

  health_check {
    healthy_threshold   = var.elb_healthy_threshold
    unhealthy_threshold = var.elb_unhealthy_threshold
    timeout             = var.elb_timeout
    target              = "HTTP:80/index.html"
    interval            = var.elb_interval
  }

  cross_zone_load_balancing   = true
  idle_timeout                = var.elb_timeout
  connection_draining         = true
  connection_draining_timeout = var.elb_drain_timeout

  tags = {
    name = "group3_web_elb"
  }
}

resource "aws_elb" "group3_app_elb" {
  name = "group3-app-elb"

  subnets = [aws_subnet.group3_private3_subnet.id,
  aws_subnet.group3_private4_subnet.id]

  security_groups = [aws_security_group.group3_app_sg.id]

  internal = true

  listener {
    instance_port     = 80
    instance_protocol = "TCP"
    lb_port           = 80
    lb_protocol       = "TCP"
  }
  

  health_check {
    healthy_threshold   = var.elb_healthy_threshold
    unhealthy_threshold = var.elb_unhealthy_threshold
    timeout             = var.elb_timeout
    target              = "TCP:80"
    interval            = var.elb_interval
  }

  cross_zone_load_balancing   = true
  idle_timeout                = var.elb_idle_timeout
  connection_draining         = true
  connection_draining_timeout = var.elb_drain_timeout

  tags = {
    name = "group3_app_elb"
  }
}


# resource "aws_key_pair" "keypair1" {
#   key_name   = "${var.stack}-keypairs"
#   public_key = file(var.ssh_key)
# }

#---RDS Instances---

resource "aws_db_instance" "group3_primary_db" {
 allocated_storage       = 10
 storage_type           = "gp2"
 engine                  = "mysql"
 engine_version          = "5.7"
 instance_class          = var.db_instance_class
 name                    = var.db_name
 username                = var.db_user
 password                = var.db_password
 db_subnet_group_name    = aws_db_subnet_group.group3_rds_subnetgroup.name
 vpc_security_group_ids  = [aws_security_group.group3_rds_sg.id]
 skip_final_snapshot     = true
 availability_zone       = data.aws_availability_zones.available.names[0]
 apply_immediately       = false
 backup_retention_period = var.db_bak_retention
 deletion_protection     = false
 publicly_accessible     = false

}



# resource "aws_db_instance" "group3_replica_db" {

#   instance_class         = var.db_instance_class
#   vpc_security_group_ids = [aws_security_group.group3_rds_sg.id]
#   availability_zone      = data.aws_availability_zones.available.names[1]

#   replicate_source_db = aws_db_instance.group3_primary_db.id
# }


#---ASG Configs---

# Private level 1

# Using standard AWS AMI for tnis exercise
resource "aws_launch_configuration" "group3_web_lc" {
  name_prefix     = "group3_web_lc-"
  image_id        = var.web_ami
  instance_type   = var.web_lc_instance_type
  security_groups = [aws_security_group.group3_web_sg.id]
  user_data = file("files/userdatawp.sh")
  key_name             = var.key_name
  

  # provisioner "file" {
  #   source      = "files/userdatawp.sh"
  #   destination = "/tmp/userdatawp.sh"

 #     connection {
 #       type        = "ssh"
 #       user        = "ec2_user"
 #       host = self.public_ip
 #       private_key = file(var.ssh_priv_key)
 #     }
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "chmod +x /tmp/userdatawp.sh",
  #     "/tmp/userdatawp.sh",
  #   ]

  #   connection {
  #     type        = "ssh"
  #     user        = "ec2_user"
  #     host = self.public_ip
  #     private_key = file(var.ssh_priv_key)
  #   }
  # }

  # provisioner "file" {
  #   content     = data.template_file.phpconfig.rendered
  #   destination = "/tmp/wp-config.php"

  #   connection {
  #     type        = "ssh"
  #     user        = "ec2_user"
  #     host = self.public_ip
  #     private_key = file(var.ssh_priv_key)
  #   }
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo cp /tmp/wp-config.php /var/www/html/wp-config.php",
  #   ]

#     connection {
#       type        = "ssh"
#       user        = "ec2_user"
#       host = self.public_ip
#       private_key = file(var.ssh_priv_key)
#     }
  # }


  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "group3_web_asg" {
  name                      = aws_launch_configuration.group3_web_lc.id
  max_size                  = var.asg_web_max
  min_size                  = var.asg_web_min
  health_check_grace_period = var.asg_web_grace
  health_check_type         = var.asg_web_hct
  desired_capacity          = var.asg_web_cap
  force_delete              = true
  load_balancers            = [aws_elb.group3_web_elb.name]
  launch_configuration = aws_launch_configuration.group3_web_lc.name

  vpc_zone_identifier = [aws_subnet.group3_private1_subnet.id,
  aws_subnet.group3_private2_subnet.id]

  #availability_zones = [data.aws_availability_zones.available.names[0],data.aws_availability_zones.available.names[1]]

  tag {
    key                 = "Name"
    value               = "group3_web-instance"
    propagate_at_launch = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}


# Private Level 2

# Using standard AWS AMI for this exercise
resource "aws_launch_configuration" "group3_app_lc" {
  name_prefix     = "group3_app_lc-"
  image_id        = var.app_ami
  instance_type   = var.app_lc_instance_type
  security_groups = [aws_security_group.group3_app_sg.id]
  user_data       = file("userdata.sh")
  key_name             = var.key_name
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "group3_app_asg" {
  name                      = aws_launch_configuration.group3_app_lc.id
  max_size                  = var.asg_app_max
  min_size                  = var.asg_app_min
  health_check_grace_period = var.asg_app_grace
  health_check_type         = var.asg_app_hct
  desired_capacity          = var.asg_app_cap
  force_delete              = true
  load_balancers            = [aws_elb.group3_app_elb.name]
  launch_configuration = aws_launch_configuration.group3_app_lc.name

  vpc_zone_identifier = [aws_subnet.group3_private3_subnet.id,
  aws_subnet.group3_private4_subnet.id]

  #availability_zones = [data.aws_availability_zones.available.names[0],data.aws_availability_zones.available.names[1]]

  tag {
    key                 = "Name"
    value               = "group3_app-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
