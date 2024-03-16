resource "tls_private_key" "ec2_keys" {
  count     = length(var.instance_names)
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "deployer-key"
  public_key = public_key = tls_private_key.ec2_keys.public_key_openssh
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
  instance_type               = var.size
  key_name                    = [aws_key_pair.ssh_key.fingerprint]
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true


  provisioner "local-exec" {
    depends_on = [aws_instance.django]
    command = "ansible-playbook -i ${path.module}/ansible/inventory/inventory ${path.module}/ansible/playbook.yml --private-key ${path.module}/private_key.pem" 
  }

  tags = {
    Name = "web-production"
  }
}
