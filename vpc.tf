provider "aws" {
  region = var.region
  access_key = ""
  secret_key = ""
}

#Create vpc
resource "aws_vpc" "omik-proj-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "omik-proj-vpc"
  }
}

#Create internet gateway
resource "aws_internet_gateway" "omik-ig" {
  vpc_id = aws_vpc.omik-proj-vpc.id
  tags = {
    Name = "omik-ig"
  }
}

#Create public subnets 
resource "aws_subnet" "omik-pub-subs" {
  count = length(var.cidr_pub_sub)
  cidr_block = var.cidr_pub_sub[count.index]
  vpc_id = aws_vpc.omik-proj-vpc.id
  availability_zone = "us-east-1${var.avail_zone[count.index]}"
  tags = {
    Name = "omik-pub-sub${count.index + 1}"
  }
  depends_on = [ aws_vpc.omik-proj-vpc ]
}


#Create private subnets
resource "aws_subnet" "omik-priv-subs" {
  count = length(var.cidr_priv_sub)
  cidr_block = var.cidr_priv_sub[count.index]
  vpc_id = aws_vpc.omik-proj-vpc.id
  availability_zone = "us-east-1${var.avail_zone[count.index]}"
  tags = {
    Name = "omik-priv-sub${count.index + 1}"
  }
  depends_on = [ aws_vpc.omik-proj-vpc ]
}



#Create public route table
resource "aws_route_table" "omik-pub-route" {
    vpc_id = aws_vpc.omik-proj-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.omik-ig.id
    }
    tags = {
        Name = "omik-proj-pub-route"
    }
    depends_on = [ aws_subnet.omik-pub-subs ]
}

#Associating routes to public route table
resource "aws_route_table_association" "pub-routes-asso" {
  count = length(var.cidr_pub_sub)
  subnet_id = aws_subnet.omik-pub-subs[count.index].id
  route_table_id = aws_route_table.omik-pub-route.id
  depends_on = [ aws_subnet.omik-pub-subs, aws_route_table.omik-pub-route ]
}

#Creating Elastic IP for Nat gateway
resource "aws_eip" "omik-proj-eip" {
  domain = "vpc"
}

#Creating NAT and associating VPC
resource "aws_nat_gateway" "omik-nat" {
  allocation_id = aws_eip.omik-proj-eip.id
  subnet_id = aws_subnet.omik-pub-subs[1].id
  depends_on = [ aws_internet_gateway.omik-ig, aws_subnet.omik-pub-subs ]
}

#Creating private route table
resource "aws_route_table" "omik-priv-route" {
  vpc_id = aws_vpc.omik-proj-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.omik-nat.id
  }
  tags = {
    Name = "omik-proj-priv-route"
  }
  depends_on = [ aws_subnet.omik-priv-subs ]
}

#Associating route table to private subnets
resource "aws_route_table_association" "priv-route-asso" {
  count = length(var.cidr_priv_sub)
  subnet_id = aws_subnet.omik-priv-subs[count.index].id
  route_table_id = aws_route_table.omik-priv-route.id
  depends_on = [ aws_subnet.omik-priv-subs, aws_route_table.omik-priv-route ]
}
