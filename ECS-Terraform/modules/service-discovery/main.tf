resource "aws_service_discovery_private_dns_namespace" "main" {
  name = "${var.app_name}.${var.stage_name}.ecs.microservices.local"
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

output "mysqldb_service_name" {
  value = "${aws_service_discovery_service.mysql_db_microservice.name}.${aws_service_discovery_private_dns_namespace.main.name}"
}

output "mysqldb_registry_arn" {
  value = aws_service_discovery_service.mysql_db_microservice.arn
}