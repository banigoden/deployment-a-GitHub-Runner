provider "aws" {
  profile = "default"
  region  = var.aws_region
}

# Declare the VPC resource
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "vpc_production"
  }
}

#the public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.subnet_cidr_block
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true
}

# Create an Internet Gateway for public subnet
resource "aws_internet_gateway" "gw1" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "IGW_production"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw1.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

# Associate public route table with public subnet
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# The private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_cidr_block
  availability_zone = "eu-central-1b"
}

# Create a private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  # You can add specific routes for private subnet if needed
  tags = {
    Name = "Private Route Table"
  }
}

# Associate private route table with private subnet
resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# Create an AWS security group allowing SSH access
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow inbound SSH traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "tls_private_key" "ec2_keys" {
  count     = length(var.instance_names)
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ec2_files" {
  count    = length(var.instance_names)
  content  = tls_private_key.ec2_keys[count.index].private_key_pem
  filename = "EC2-${var.instance_names[count.index]}"
}

resource "local_sensitive_file" "pem_files" {
  count                = length(var.instance_names)
  filename             = "~/.ssh/EC2-${var.instance_names[count.index]}.pem"
  file_permission      = "0600"
  directory_permission = "0700"
  content              = tls_private_key.ec2_keys[count.index].private_key_pem
}

# Create an AWS instance
resource "aws_instance" "django" {
  ami                         = var.ami_number
  instance_type               = "t2.micro"
  key_name                    = "EC2-${var.instance_names[0]}.pem"
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true


  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}/ansible/inventory/inventory.ini ${path.module}/ansible/playbook.yml"
  }

  tags = {
    Name = "web-production"
  }
}

resource "aws_instance" "monitoring" {
  ami                         = var.ami_number
  instance_type               = "t2.micro"
  key_name                    = "EC2-${var.instance_names[1]}.pem"
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true

  tags = {
    Name = "monitoring"
  }
}
