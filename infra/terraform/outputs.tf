output "vpc_id" {
  value = aws_vpc.main.id
}

output "subredes_publicas" {
  value = aws_subnet.publica[*].id
}

output "subredes_privadas" {
  value = aws_subnet.privada[*].id
}

output "ecr_url" {
  value = aws_ecr_repository.app.repository_url
}

output "rol_github_arn" {
  value = aws_iam_role.github_actions.arn
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}

output "rds_secret_arn" {
  value = aws_db_instance.postgres.master_user_secret[0].secret_arn
}
