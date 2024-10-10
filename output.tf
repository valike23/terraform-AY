# outputs.tf

output "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.my_ecs_cluster.id
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.my_ecs_service.name
}

output "security_group_id" {
  description = "The security group ID for the ECS service"
  value       = aws_security_group.ecs_service_sg.id
}
