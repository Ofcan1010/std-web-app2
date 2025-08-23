output "public_ip"   { value = aws_instance.std.public_ip }
output "instance_id" { value = aws_instance.std.id }