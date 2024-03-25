output "public_ip" {
  value = aws_instance.django.public_ip
}

output "public_dns" {
  value = aws_instance.django.public_dns
}

output "region" {
  value = var.aws_region
}
