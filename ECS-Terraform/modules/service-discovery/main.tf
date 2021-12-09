resource "random_uuid" "random" {}

resource "aws_service_discovery_private_dns_namespace" "main" {
  name = "${var.app_name}.${var.stage_name}.ecs.microservices.pvt.${random_uuid.random.result}"
  vpc  = var.vpcid
}

resource "aws_service_discovery_service" "mysql_db_microservice" {
  name = "mysqldb"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 300
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "progress_tracker_microservice" {
  name = "progress-tracker"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 300
      type = "A"
      # required for bridge & host n/w modes
      #type = "SRV"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

output "mysqldb_discovery_service_name" {
  value = "${aws_service_discovery_service.mysql_db_microservice.name}.${aws_service_discovery_private_dns_namespace.main.name}"
}

output "mysqldb_discovery_service_registry_arn" {
  value = aws_service_discovery_service.mysql_db_microservice.arn
}

output "progress_tracker_discovery_service_name" {
  value = "${aws_service_discovery_service.progress_tracker_microservice.name}.${aws_service_discovery_private_dns_namespace.main.name}"
}

output "progress_tracker_discovery_service_registry_arn" {
  value = aws_service_discovery_service.progress_tracker_microservice.arn
}
