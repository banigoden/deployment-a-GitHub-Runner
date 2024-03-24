resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "EC2-${var.instance_name}"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

resource "local_sensitive_file" "pem_files" {
  filename        = "${path.module}./ansible/EC2-${var.instance_name}.pem"
  file_permission = "0600"
  # directory_permission = "0700"
  content = tls_private_key.ec2_key.private_key_pem
}

# Create an AWS instance
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
  depends_on = [aws_instance.django]

  #Because AWS instance needs some time to be ready for usage we will use below trick with remote-exec.
  #As per documentation remote-exec waits for successful connection and only after this runs command.
  provisioner "remote-exec" {
    inline = ["sudo hostname"]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.module}./ansible/EC2-django.pem")
      host        = self.public_ip
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}./ansible/inventory.tpl ${path.module}./ansible/playbook.yml --private-key ${path.module}./ansible/EC2-django.pem --user ec2-user"
  }

}
