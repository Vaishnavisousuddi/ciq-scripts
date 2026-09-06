output "subnet_ids" {
  description = "Map of subnet name -> subnet ID, same keys as var.subnets"
  value       = { for name, s in aws_subnet.workload_subnet : name => s.id }
}
