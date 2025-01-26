output "rds_endpoint" {
  value       = aws_db_instance.rds_instance.endpoint
  description = "The endpoint of the RDS instance"
}

output "rds_arn" {
  value       = aws_db_instance.rds_instance.arn
  description = "The ARN of the RDS instance"
}