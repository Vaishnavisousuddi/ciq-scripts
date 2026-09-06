##############################################################################
# EKS Access Entries - explicit, not relying on the implicit "cluster
# creator gets admin" behavior (access_config.bootstrap_cluster_creator_admin_permissions).
# That implicit grant only covers the exact identity that ran CreateCluster,
# which is why a separate console session or a different terminal/CLI
# identity can hit "Unauthorized" even though the cluster creator's own
# session works fine.
#
# Always grants cluster-admin to whoever is currently running Terraform
# (data.aws_caller_identity.current), plus anyone listed in
# var.eks_admin_principal_arns - add an ARN there in tfvars to grant access
# to another person/role, no code change needed.
##############################################################################

data "aws_caller_identity" "current" {}

# aws_caller_identity returns the STS assumed-role ARN (with session name)
# when running under an assumed role (e.g. SSO) - EKS access entries need
# the underlying IAM role ARN instead. aws_iam_session_context resolves
# that correctly; for an IAM user (not an assumed role) it passes through
# unchanged.
data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

locals {
  eks_admin_principal_arns = toset(concat(
    [data.aws_iam_session_context.current.issuer_arn],
    var.eks_admin_principal_arns
  ))
}

resource "aws_eks_access_entry" "admin" {
  for_each = local.eks_admin_principal_arns

  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = each.value
}

resource "aws_eks_access_policy_association" "admin" {
  for_each = local.eks_admin_principal_arns

  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = each.value
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admin]
}