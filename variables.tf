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

variable "amis" {
  description = "Which AMI to spawn."
  default = {
    us-east-2 = "ami-0effacb21ac1c631a"
  }
}

variable "ecs_container_config" {
  description = "configuration variables for ecs cluster containers"
  type = map(object({
    templatePath             = string
    cpu                      = number
    memory                   = number
    image                    = string
    name                     = string
    containerPort            = number
    hostPort                 = number
    enable_service_discovery = bool
  }))
}

variable "ecs_task_definition_config" {
  description = "configuration variables for ecs task definitions"
  type = map(object({
    cpu    = number
    memory = number
  }))
}

variable "ecs_service_config" {
  description = "configuration variables for ecs service"
  type = map(object({
    desired_count              = number
    create_loadbalancer        = bool
    associate_service_registry = bool
  }))
}

variable "env" {
  description = "Infrastructure environment e.g dev,test,prod. Used in resource tags"
  type        = string
}
