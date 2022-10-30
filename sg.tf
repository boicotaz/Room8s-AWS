# ALB Security Group (Traffic Internet -> ALB)
resource "aws_security_group" "load_balancer" {

  name        = "lb-sg"
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

# ECS Security group (traffic ALB -> ECS, ssh -> ECS)
resource "aws_security_group" "ecs_service" {

  name        = "HTTP"
  description = "Allow all HTTP inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "HTTP from anywhere"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer.id]
    #cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}
