output "alb_dns_name" {
  description = "Public DNS name of the ALB — use this to test the deployed service"
  value       = aws_lb.main.dns_name
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}

output "rds_endpoint" {
  description = "RDS endpoint (only reachable from inside the VPC — not public)"
  value       = aws_db_instance.main.endpoint
}

output "sns_topic_arn" {
  value = aws_sns_topic.alarms.arn
}

output "cloudwatch_dashboard_name" {
  value = aws_cloudwatch_dashboard.main.dashboard_name
}

output "ecr_repository_url" {
  description = "ECR repository URL — push your app image here"
  value       = aws_ecr_repository.app.repository_url
}
