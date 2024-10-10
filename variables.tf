# variables.tf

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  default     = "us-east-1"  
}

variable "vpc_id" {
  description = "The ID of the existing VPC"
  type        = string
}

variable "subnet_ids" {
  description = "The list of subnet IDs in the existing VPC"
  type        = list(string)
}

variable "container_image" {
  description = "The Docker image to use for the ECS task"
  default     = "nginx"  
}

variable "container_port" {
  description = "The port the container listens to"
  default     = 80
}
