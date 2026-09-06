output "vpc_id" {
  value = module.vpc.vpc_id
}

output "secondary_cidr_block" {
  value = module.vpc.secondary_cidr_block
}

output "subnet_ids" {
  description = "Map of subnet name -> subnet ID"
  value       = module.subnets.subnet_ids
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_nodes_sg_id" {
  value = module.eks.eks_nodes_sg_id
}

output "eks_oidc_provider_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "state_bucket_name" {
  value = aws_s3_bucket.terraform_state.id
}
output "lock_table_name" {
  value = aws_dynamodb_table.terraform_locks.name
}
output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}