# ALB Security Group (Traffic Internet -> ALB)
resource "aws_security_group" "load_balancer" {

  name        = "loadbalancer-sg"
  description = "Allow access to lb to port 80"
  vpc_id      = module.vpc.vpc_id


  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

# ECS Instance Security group (traffic ALB -> ECS)
resource "aws_security_group" "ecs" {

  name        = "ecs-instance-sg"
  description = "Allow inbound traffic from LB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    # Container Port allocation is randomized in ECS Container Host, hence the following rule
    description     = "ALL traffic from LB"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.load_balancer.id]
  }

  ingress {
    description = "ssh from ME"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.personal_access}"]
  }

  egress {
    description      = "Allow ALL Outgoing traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

# VPC Endpoint SG
resource "aws_security_group" "vpc-endpoints" {
  vpc_id      = module.vpc.vpc_id
  name        = "vpc-endpoint-sg"
  description = "Enable endpoint connection (HTTPS) from ecs container instances"
  ingress {
    description     = "HTTPS Access from ECS instance SG"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    description      = "Allow ALL Outgoing traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}
