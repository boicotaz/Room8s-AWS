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

variable "container_defenitions_path" {
  description = "Path to container definitions file"
  type        = list(string)
  default     = ["container_definitions/quickstart.json.tpl"]
}

variable "ecr_repo_url" {
  description = "Url for the ECR that contains the image for the cluster"
  type        = string
}

variable "amis" {
  description = "Which AMI to spawn."
  default = {
    us-east-2 = "ami-0effacb21ac1c631a"
  }
}
