# Define local variables for reusability
locals {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = var.aws_vpc_cidr
}

# Create a VPC resource
resource "aws_vpc" "demo-vpc" {
  cidr_block           = local.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "demo vpc"
  }
}

# Create public subnets within the VPC
resource "aws_subnet" "public-subnet" {
  vpc_id = local.vpc_id
  count  = length(var.public_subnet_cidr)

  cidr_block        = element(var.public_subnet_cidr, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "public subnet ${count.index + 1}"
  }
}

# Create private subnets within the VPC
resource "aws_subnet" "private-subnet" {
  vpc_id = local.vpc_id
  count  = length(var.private_subnet_cidr)

  cidr_block        = element(var.private_subnet_cidr, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "private subnet ${count.index + 1}"
  }
}

# Create an internet gateway for the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = local.vpc_id

  tags = {
    Name = "vpc igw"
  }
}

# Create a public route table and associate it with the VPC
resource "aws_route_table" "public-route-table" {
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public-subnet-association" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.public-route-table.id
}

# Create a security group for instances in the VPC
resource "aws_security_group" "demo-sg" {
  vpc_id = aws_vpc.demo-vpc.id
  name   = "demo-sg"

  # Allow inbound traffic on specified ports (SSH, HTTP, HTTPS)
  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demo-sg"
  }
}

resource "aws_key_pair" "test" {
  key_name   = "test"
  public_key = tls_private_key.rsa.public_key_openssh

}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "test" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "test-key"

  provisioner "local-exec" {
    command = "chmod 600 ${local_file.test.filename}"

  }


# Create EC2 instances within the VPC (4 Linux in private, and one Windows in public)
resource "aws_instance" "linux_instances" {
  ami           = var.ami_id_linux
  instance_type = var.instance_types[count.index]
  count = 4

  subnet_id       = aws_subnet.private-subnet[0].id
  security_groups = [aws_security_group.demo-sg.id]
  key_name        = aws_key_pair.public.key_name
  associate_public_ip_address = true

  tags = {
    Name = "LinuxInstance"
  }
}

resource "aws_instance" "windows_instance" {
  ami           = var.ami_id_windows
  instance_type = var.instance_types[4]
  count = 1
  subnet_id       = aws_subnet.public-subnet[0].id
  security_groups = [aws_security_group.demo-sg.id]

  tags = {
    Name = "WindowsInstance"
  }
}
