
resource "local_file" "inventory" {
  filename        = "${path.module}./ansible/inventory/ansible-inventory"
  file_permission = "0640"
  content = templatefile("${path.module}/templates/inventory.tftpl",
    {
      region             = var.aws_region
      instance_public_ip = aws_instance.django.public_ip
      GIT_TOKEN_MY       = var.GIT_TOKEN
    }
  )
  depends_on = [aws_instance.django]
}
