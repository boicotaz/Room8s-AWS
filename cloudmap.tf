resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = "room8s"
  description = "backend pricate dns namespace"
  vpc         = module.vpc.vpc_id
}

resource "aws_service_discovery_service" "this" {
  name = "backend-service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 5
      type = "SRV"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
