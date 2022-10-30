variable "ecs_cluster_name" {
  description = "The ECS cluster name"
  type        = string
  default     = "Room8s"
}

variable "health_check_path" {
  description = "URI to check for container health"
  type        = string
  default     = "/"
}

variable "personal_access" {
  description = "Personal public ip address. Used in default sg to allow access to all aws resources"
  type        = string
}

variable "log_retention_in_days" {
  description = "Amount of time in days to keep logs"
  type        = number
  default     = 7
}

variable "aws_region" {
  description = "AWS region to deploy infra"
  type        = string
  default     = "us-east-2"

}