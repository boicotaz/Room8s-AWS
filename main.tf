provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
      Environment = "${var.env}"
    }
  }

}

module "vpc_endpoints" {
  source = "../modules/network/vpc-endpoints"
  vpc_id = module.vpc.vpc_id
  vpc_endpoints = {
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      security_group_ids  = [aws_security_group.vpc-endpoints.id]
    }
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      security_group_ids  = [aws_security_group.vpc-endpoints.id]
    }
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = [module.vpc.private_route_table_id]
    }
    ecs = {
      service             = "ecs"
      private_dns_enabled = true
      security_group_ids  = [aws_security_group.vpc-endpoints.id]
    }
    ecs_agent = {
      service             = "ecs-agent"
      private_dns_enabled = true
      security_group_ids  = [aws_security_group.vpc-endpoints.id]
    }
    ecs_telemetry = {
      service             = "ecs-telemetry"
      private_dns_enabled = true
      security_group_ids  = [aws_security_group.vpc-endpoints.id]
    }
    logs = {
      service             = "logs"
      private_dns_enabled = true
      security_group_ids  = [aws_security_group.vpc-endpoints.id]
    }
  }
  subnet_ids = module.vpc.private_subnets
}

module "vpc" {
  source          = "../modules/network/vpc"
  name            = "ecscluster"
  cidr            = "10.0.0.0/16"
  create_igw      = true
  create_ngw      = false
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  manage_default_security_group = true
  default_security_group_ingress = [
    {
      self      = true
      protocol  = "-1"
      from_port = "0"
      to_port   = "0"
    },
    {
      protocol    = "tcp"
      from_port   = "22"
      to_port     = "22"
      cidr_blocks = "${var.personal_access}"
      description = "Allow personal SSH access"
    }
  ]
  default_security_group_egress = [
    {
      protocol    = "-1"
      from_port   = "0"
      to_port     = "0"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}
