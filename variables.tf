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

variable "backend_container_defenition_path" {
  description = "Path to backend container definition file"
  type        = list(string)
  default     = ["container_definitions/backend_container_definition.json.tpl"]
}

variable "frontend_container_defenition_path" {
  description = "Path to front end container definition file"
  type        = list(string)
  default     = ["container_definitions/frontend_container_definition.json.tpl"]
}

variable "amis" {
  description = "Which AMI to spawn."
  default = {
    us-east-2 = "ami-0effacb21ac1c631a"
  }
}

variable "backend_container_config" {
  description = "configuration variables for backend container"
  type = object({
    cpu           = number
    memory        = number
    image         = string
    name          = string
    containerPort = number
    hostPort      = number
  })

}

variable "frontend_container_config" {
  description = "configuration variables for backend container"
  type = object({
    cpu           = number
    memory        = number
    image         = string
    name          = string
    containerPort = number
    hostPort      = number
  })

}

variable "container_config" {
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

variable "env" {
  description = "Infrastructure environment e.g dev,test,prod. Used in resource tags"
  type        = string
}
