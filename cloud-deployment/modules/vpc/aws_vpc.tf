#### Resource: aws_vpc (provides a VPC resource)
#### and associated resources for vpc.

#### Create a VPC
resource "aws_vpc" "redis_cluster_vpc" {
  cidr_block                  = var.vpc_cidr
  enable_dns_support          = true
  enable_dns_hostnames        = true

  tags = {
    Name = format("%s-%s-cluster-vpc", var.base_name, var.region),
    Project = format("%s-%s-cluster", var.base_name, var.region),
    Owner = var.owner
  }
}

data "aws_vpc" "re-vpc-data" {
  id = aws_vpc.redis_cluster_vpc.id
}


#### Create private subnets
resource "aws_subnet" "re_subnet1" {
  vpc_id     = aws_vpc.redis_cluster_vpc.id
  cidr_block = var.subnet_cidr_blocks[0]
  availability_zone = var.subnet_azs[0]

  tags = {
    Name = format("%s-subnet1", var.base_name),
    Project = format("%s-%s-cluster", var.base_name, var.region),
    Owner = var.owner
  }
}

resource "aws_subnet" "re_subnet2" {
  vpc_id     = aws_vpc.redis_cluster_vpc.id
  cidr_block = var.subnet_cidr_blocks[1]
  availability_zone = var.subnet_azs[1]

  tags = {
    Name = format("%s-subnet2", var.base_name),
    Project = format("%s-%s-cluster", var.base_name, var.region),
    Owner = var.owner
  }
}

resource "aws_subnet" "re_subnet3" {
  vpc_id     = aws_vpc.redis_cluster_vpc.id
  cidr_block = var.subnet_cidr_blocks[2]
  availability_zone = var.subnet_azs[2]

  tags = {
    Name = format("%s-subnet3", var.base_name),
    Project = format("%s-%s-cluster", var.base_name, var.region),
    Owner = var.owner
  }
}

#### network
#### Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.redis_cluster_vpc.id
  tags = {
      Name = format("%s-igw", var.base_name),
      Project = format("%s-%s-cluster", var.base_name, var.region),
      Owner = var.owner
    }
}

#### Create a custom route table
#### (custom route table for the subnet)
resource "aws_default_route_table" "route_table" {
  default_route_table_id = aws_vpc.redis_cluster_vpc.default_route_table_id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
    }
  tags = {
      Name = format("%s-rt", var.base_name),
      Project = format("%s-%s-cluster", var.base_name, var.region),
      Owner = var.owner
    }
}

#### associate the route table to the subnet.
resource "aws_route_table_association" "subnet_association1" {
  subnet_id      = aws_subnet.re_subnet1.id
  route_table_id = aws_default_route_table.route_table.id
}
resource "aws_route_table_association" "subnet_association2" {
  subnet_id      = aws_subnet.re_subnet2.id
  route_table_id = aws_default_route_table.route_table.id
}
resource "aws_route_table_association" "subnet_association3" {
  subnet_id      = aws_subnet.re_subnet3.id
  route_table_id = aws_default_route_table.route_table.id
}