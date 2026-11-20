output "alb_dns_name" {
  description = "DNS público del ALB (único punto de entrada)"
  value       = aws_lb.alb_public.dns_name
}

output "ecr_repository_url" {
  description = "Repositorio ECR de la imagen de la API"
  value       = aws_ecr_repository.ecr_repo.repository_url
}
