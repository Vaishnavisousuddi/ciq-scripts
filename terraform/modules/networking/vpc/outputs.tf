output "vpc_id" {
  value = data.aws_vpc.existing.id
}

output "vpc_primary_cidr_block" {
  description = "The VPC's original CIDR (10.118.0.0/16) - untouched by this module, exposed for reference only"
  value       = data.aws_vpc.existing.cidr_block
}

output "secondary_cidr_block" {
  value = aws_vpc_ipv4_cidr_block_association.secondary_cidr.cidr_block
}

output "secondary_cidr_association_id" {
  description = "Used by the subnets module (via depends_on at the module call site) to guarantee the secondary CIDR is attached before any subnet is carved out of it"
  value       = aws_vpc_ipv4_cidr_block_association.secondary_cidr.id
}
