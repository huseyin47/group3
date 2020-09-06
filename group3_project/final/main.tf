
# Creation of S3

data "aws_caller_identity" "current" {}


module "group3-s3-utility-bucket-test" {
  source      = "./module/s3"
  bucket_name = "group3-s3-utility-bucket-test"
  s3_tags = {
    Name = "group3-s3-utility-bucket-test"
  }
}

# resource "aws_key_pair" "key_name" {
#   key_name   = var.key_name
#   public_key = file(var.ssh_key)
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
  vpc = true
  associate_with_private_ip = "10.0.0.5"
}
resource "aws_nat_gateway" "group3_nat" {
  allocation_id = aws_eip.group3_eip.id
  subnet_id     = aws_subnet.group3_public1_subnet.id
  depends_on    = [aws_eip.group3_eip]
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
# resource "aws_network_acl" "allowall" {
#   vpc_id = aws_vpc.group3_vpc.id
#   egress {
#     protocol   = "-1"
#     rule_no    = 100
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 0
#     to_port    = 0
#   }
#   ingress {
#     protocol   = "-1" #means allowing all protocols
#     rule_no    = 200
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 0
#     to_port    = 0
#   }
# }






