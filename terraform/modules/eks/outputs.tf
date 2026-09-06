output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.eks_cluster_sg.id
}

output "eks_nodes_sg_id" {
  description = "Security Group ID for EKS worker nodes"
  value       = aws_security_group.eks_nodes_sg.id
}


output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = aws_iam_role.eks_cluster_role.name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN associated with EKS cluster"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "worker_iam_role_name" {
  description = "IAM role name associated with EKS worker nodes"
  value       = aws_iam_role.eks_node_group_role.name
}

output "worker_iam_role_arn" {
  description = "IAM role ARN associated with EKS worker nodes"
  value       = aws_iam_role.eks_node_group_role.arn
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for EKS"
  value       = aws_iam_openid_connect_provider.eks_oidc_provider.arn
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

output "gp3_sc" {
  description = "Default GP3 storage class name for the EKS cluster"
  value       = "gp3"
}
