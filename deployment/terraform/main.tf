resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "EC2-${var.instance_name}"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

resource "local_sensitive_file" "pem_files" {
  filename             = "${path.module}./ansible/EC2-${var.instance_name}.pem"
  file_permission      = "0600"
  directory_permission = "0700"
  content              = tls_private_key.ec2_key.private_key_pem
}

resource "aws_instance" "django" {
  ami                         = var.ami_number
  instance_type               = var.size
  key_name                    = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true

  tags = {
    Name = "web-production"
  }

}

resource "null_resource" "run_ansible" {
  depends_on = [aws_instance.django]

  provisioner "local-exec" {
    command = "sleep 20"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}./ansible/inventory/ansible-inventory ${path.module}./ansible/playbook.yml --private-key ${path.module}./ansible/EC2-django.pem --user ec2-user -e install_github_runner_github_repo_token=${var.GIT_TOKEN}"
  }
}
