# ALB Security Group (Traffic Internet -> ALB)
resource "aws_security_group" "load-balancer" {
  name        = "load_balancer_sg"
  description = "Allow Access to 80 and 443 of LB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTPS from ME"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["87.202.119.136/32"]
  }
  ingress {
    description = "HTTP from ME"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["87.202.119.136/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
# ECS Security group (traffic ALB -> ECS, ssh -> ECS)
resource "aws_security_group" "ecs" {
  name        = "ecs_sg"
  description = "Allow Traffic from ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Allow access from ALB"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.load-balancer.id]
  }
  ingress {
    description = "ssh from ME"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["87.202.119.136/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
