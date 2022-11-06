# Create custom ecsTaskExecutionRole
# Used for access to ECR and Cloudwatch mainly
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${var.ecs_cluster_name}-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_ecs_task_role_policy.json
  tags = {
    Name = "${var.ecs_cluster_name}-ecs-task-iam-role"
  }
}

data "aws_iam_policy_document" "assume_ecs_task_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create custom ecsInstanceProfile

resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name = "ecs_instance_role"
  path = "/"
  role = aws_iam_role.ecs-instance-role.name
}

resource "aws_iam_role" "ecs-instance-role" {
  name               = "ecs_instance_role"
  assume_role_policy = data.aws_iam_policy_document.assume-ecs-instance-role-policy.json
}

data "aws_iam_policy_document" "assume-ecs-instance-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "ecs-instance-role-policy" {
  name   = "ecs_instance_role_policy"
  policy = file("policies/ecs-instance-role-policy.json")
  #policy = file("policies/ecs-role.json")
  role = aws_iam_role.ecs-instance-role.id
}
