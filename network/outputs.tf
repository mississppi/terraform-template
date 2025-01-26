# ネットワーク情報を他で利用できるようにエクスポート
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value       = [aws_subnet.public_subnet_1a.id, aws_subnet.public_subnet_1c.id]
  description = "List of public subnet IDs"
}

output "private_subnet_id" {
  value       = [aws_subnet.private_subnet_1a.id, aws_subnet.private_subnet_1c.id]
  description = "List of private subnet IDs"
}

output "public_sg_id" {
  value = aws_security_group.public_sg.id
}

output "private_sg_id" {
  value = aws_security_group.private_sg.id
}

# RDS Security Group ID Output
output "rds_sg_id" {
  value = [aws_security_group.rds_sg.id]
}

output "private_subnet_ids" {
  value       = [aws_subnet.private_subnet_1a.id, aws_subnet.private_subnet_1c.id]
  description = "List of private subnet IDs"
}