resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/templates/inventory.tftpl"
  file_permission = "0640"
  content = templatefile(
    "${path.module}/ansible/inventory",
    {
      region         = var.aws_region
    }
  )
  depends_on = [aws_instance.django]
}