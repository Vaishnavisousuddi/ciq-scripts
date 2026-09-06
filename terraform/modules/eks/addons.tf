# ------------------------------------------------------------------
# Addon versions are resolved dynamically against the cluster's own
# kubernetes_version instead of being hardcoded, so they never go stale
# and always match whatever k8s version this cluster is actually running.
#
# None of these depend_on the node group. vpc-cni and kube-proxy are
# DaemonSets - nodes need THEM to go Ready, not the other way around.
# Making them depend_on the node group created a deadlock: EKS managed
# node groups wait for nodes to be Ready before finishing creation, but
# nodes can't go Ready without vpc-cni running, and vpc-cni never got
# created because it was waiting on the node group. resolve_conflicts_on_create
# also handles the self-managed default addons EKS auto-bootstraps at
# cluster creation (bootstrap_self_managed_addons defaults to true).
# ------------------------------------------------------------------

data "aws_eks_addon_version" "vpc_cni" {
  addon_name         = "vpc-cni"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "vpc-cni"
  addon_version               = data.aws_eks_addon_version.vpc_cni.version
  resolve_conflicts_on_create = "OVERWRITE"
}

data "aws_eks_addon_version" "coredns" {
  addon_name         = "coredns"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "coredns"
  addon_version               = data.aws_eks_addon_version.coredns.version
  resolve_conflicts_on_create = "OVERWRITE"
}

# Required for the AWS Load Balancer Controller (helm/alb_controller module), which
# authenticates via aws_eks_pod_identity_association rather than IRSA/OIDC.
data "aws_eks_addon_version" "pod_identity_agent" {
  addon_name         = "eks-pod-identity-agent"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "eks-pod-identity-agent"
  addon_version               = data.aws_eks_addon_version.pod_identity_agent.version
  resolve_conflicts_on_create = "OVERWRITE"
}

data "aws_eks_addon_version" "kube_proxy" {
  addon_name         = "kube-proxy"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "kube-proxy"
  addon_version               = data.aws_eks_addon_version.kube_proxy.version
  resolve_conflicts_on_create = "OVERWRITE"
}

data "aws_iam_policy_document" "ebs_csi_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_oidc_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_oidc_provider.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "ebs_csi_driver" {
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role_policy.json
  name               = "${var.cluster_name}-ebs-csi-driver"
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver.name
}

data "aws_eks_addon_version" "ebs_csi_driver" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "aws-ebs-csi-driver"
  service_account_role_arn    = aws_iam_role.ebs_csi_driver.arn
  addon_version               = data.aws_eks_addon_version.ebs_csi_driver.version
  resolve_conflicts_on_create = "OVERWRITE"
}



# data "aws_iam_policy_document" "efs_csi_assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_iam_openid_connect_provider.eks_oidc_provider.url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
#     }

#     principals {
#       identifiers = [aws_iam_openid_connect_provider.eks_oidc_provider.arn]
#       type        = "Federated"
#     }
#   }
# }

# resource "aws_iam_role" "efs_csi_driver" {
#   name               = "${var.cluster_name}-efs-csi-driver"
#   assume_role_policy = data.aws_iam_policy_document.efs_csi_assume_role_policy.json
# }

# resource "aws_iam_role_policy_attachment" "efs_csi_driver" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
#   role       = aws_iam_role.efs_csi_driver.name
# }


# resource "aws_eks_addon" "aws_efs_csi_driver" {
#   cluster_name             = aws_eks_cluster.eks_cluster.name
#   addon_name               = "aws-efs-csi-driver"
#   service_account_role_arn = aws_iam_role.efs_csi_driver.arn
#   addon_version            = "v2.1.6-eksbuild.1"
#   depends_on = [aws_eks_node_group.eks_node_group]
# }