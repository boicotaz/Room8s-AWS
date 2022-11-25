[
  {
    "image": "${image}",
    "cpu": "${cpu}",
    "memory": "${memory}",
    "name": "${name}",
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
        "containerPort": "${containerPort}",
        "hostPort": "${hostPort}"
      }
    ]
  }
]
