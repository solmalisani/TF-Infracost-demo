output "vpc_id" {
  value = aws_vpc.main.id
}

output "instance_id" {
  value = aws_instance.app.id
}

output "ssm_connect_command" {
  value = "aws ssm start-session --target ${aws_instance.app.id} --region ${var.region}"
}

output "db_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "db_secret_arn" {
  value = aws_db_instance.main.master_user_secret[0].secret_arn
}
