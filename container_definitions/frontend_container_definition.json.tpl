[
  {
    "image": "${image}",
    "cpu": ${cpu},
    "memory": ${memory},
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
        "containerPort": ${containerPort},
        "hostPort": ${hostPort}
      }
    ],
    "environment": [
      {
        "name": "PORT",
        "value": "80"
      },
      {
        "name": "backend_service_dns_records",
        "value": "${backend-service-dns}"
      }
    ]
  }
]
