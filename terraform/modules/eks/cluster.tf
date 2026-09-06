resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.cluster_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
  }

  # Required for aws_eks_access_entry (used by karpenter-iam) to work - without this,
  # access entries fail with "AccessEntry can only be used with clusters that support
  # the API authentication mode."
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
    # bootstrap_cluster_creator_admin_permissions = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_policy,
  ]
  tags = merge(
  var.common_tags,
  { Name = var.cluster_name }
)

}


resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc_tls_certificate.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

data "tls_certificate" "eks_oidc_tls_certificate" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}
