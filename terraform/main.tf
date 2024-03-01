provider "aws" {
  profile = "default"
  region  = var.aws_region
}

# Declare the VPC resource
resource "aws_vpc" "my_vpc" {
  cidr_block       = "192.168.0.0/16"

  tags = {
    Name = "vpc_production"
  }
}

#the public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "192.168.1.0/24" #2.0
  availability_zone        = "eu-central-1a"
  map_public_ip_on_launch  = true
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
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "192.168.2.0/24"
  availability_zone        = "eu-central-1b"
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

# Create an AWS instance
resource "aws_instance" "django" {
  ami                         = "ami-0a23a9827c6dab833"
  instance_type               = "t2.micro"
  key_name                    = "EC2-django"
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true

  tags = {
    Name = "web-production"
  }

  # # Wait for SSH to become available
  # provisioner "remote-exec" {

  #    connection {
  #     type        = "ssh"
  #     user        = "ec2-user"  # Replace with your SSH username
  #     private_key = file("/Users/denisbandurin/Desktop/django_project/terraform/EC2-django.pem")  # Replace with your private key file path
  #     host        = self.public_ip  # Use the public IP of the instance
  #   }

  #   inline = [
  #     "echo 'Waiting for SSH to become available...'",
  #     "SLEEP_SECONDS=60",
  #     "sleep $SLEEP_SECONDS",
  #     # "until nc -zv -w 2 ${self.public_ip} 22; do sleep 5; done",
  #     "until ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /Users/denisbandurin/Desktop/django_project/terraform/EC2-django.pem ec2-user@${self.public_ip} 'echo SSH is available'; do",
  #     "echo 'SSH is now available.'"
  #   ]
  # }

  # Pass the public IP to Ansible inventory file
  provisioner "local-exec" {
    command = "echo ${self.public_ip} > /Users/denisbandurin/Desktop/django_project/ansible/inventory.txt"
  }

  # Run Ansible playbook
  provisioner "local-exec" {
    command = "ansible-playbook -i '${aws_instance.django.public_ip},' -u ec2-user --private-key=/Users/denisbandurin/Desktop/django_project/terraform/EC2-django.pem /Users/denisbandurin/Desktop/django_project/ansible/playbook.yml"
  }
}
