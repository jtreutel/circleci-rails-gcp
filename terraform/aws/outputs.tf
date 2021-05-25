output "public_ip" {
  value = aws_instance.rails_app.public_ip
}