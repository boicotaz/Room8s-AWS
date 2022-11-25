resource "aws_autoscaling_group" "ecs-cluster" {
  name                 = "${var.ecs_cluster_name}_auto_scaling_group"
  min_size             = "1"
  max_size             = "5"
  desired_capacity     = "2"
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.ecs_instance.name
  vpc_zone_identifier  = module.vpc.public_subnets
}

resource "aws_launch_configuration" "ecs_instance" {
  name                        = "${var.ecs_cluster_name}-cluster"
  image_id                    = lookup(var.amis, var.aws_region)
  instance_type               = "t2.small"
  security_groups             = [aws_security_group.ecs.id]
  iam_instance_profile        = aws_iam_instance_profile.ecs-instance-profile.name
  key_name                    = aws_key_pair.test-key.key_name
  associate_public_ip_address = true
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER='${var.ecs_cluster_name}-cluster' >> /etc/ecs/ecs.config;echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config"
}

resource "aws_key_pair" "test-key" {
  key_name   = "test-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD1taGXa7Ho9Fr5hJxEf2RdVfqT3A3XYnmoMIXM630r87T1298iP+S8PkQHWkPhM76SLRiysXVhzbOgFWc5/9/tYvMfdSKR0mkvOU1fyJufO9zduT1bC+0mU3Snin900nGD+137Y9gavh4NgVps53RTB/16PVQhtmAbeexn/WJLiQGlVbCbzkMEyHVp1u+9fqQSyPIafet8h2M8hbmjFyLSG2L/tgl6a7vkKqPjc73vIh7mJS2oTXqGE6+Ql259rJFl0vtL6QD7zK4s9Zg5E7mzl/Vv4JFYSEZe8gz6Pu8J1+hEQIO2kfSQYXP4tQo5ByMWlQC388W94z6kFQuvYaMm4pqZZnVgTn10GoV/SLJ+kBy1JLO+X9Yd8XBQwPhYH6vsP5q+aa2okS/zjTzdi4OJpg8zszoKgz0t2uGrnhRXWJMSIHisLRidZG+/7o1Ydav5/MTbVbOlH/RbHSlXzyNufzsHal+BFt2u3Urz5r5P77YMg5DjIBAwYzXHTN8x3as= vagrant@vagrant-ubuntu"
  tags = {
    env = "stage"
  }
}
