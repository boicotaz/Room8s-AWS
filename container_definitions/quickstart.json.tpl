[
  {
    "image": "${image}",
    "cpu": 512,
    "memory": 1024,
    "name": "mynginx-quickstart",
    "networkMode": "awsvpc",
    "logConfiguration": {
      "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${logs_group}",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "${logs_stream_prefix}"
        }
      },
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
