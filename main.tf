provider "aws" {
  region = "us-east-2"
}

module "vpc" {
  source                        = "../modules/network/vpc"
  name                          = "ecscluster"
  cidr                          = "10.0.0.0/16"
  create_igw                    = true
  public_subnets                = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets               = ["10.0.3.0/24", "10.0.4.0/24"]
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
