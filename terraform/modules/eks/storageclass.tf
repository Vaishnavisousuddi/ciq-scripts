resource "kubernetes_storage_class" "gp3_sc" {
    metadata {
      name = "gp3"
      annotations = {
        "storageclass.kubernetes.io/is-default-class" = "true"
      }
    }

    storage_provisioner     = "ebs.csi.aws.com"
    volume_binding_mode     = "WaitForFirstConsumer"
    reclaim_policy          = "Retain"
    allow_volume_expansion  = true

    parameters = {
      type = "gp3"
    }

    # depends_on = [ aws_eks_node_group.node_group ]
    depends_on = [ aws_eks_node_group.node_group, aws_eks_access_policy_association.admin ]
  }



# resource "kubernetes_storage_class" "s3_csi" {
#   metadata {
#     name = "s3-csi"
#   }

#   storage_provisioner = "s3.csi.aws.com"
#   reclaim_policy      = "Retain"
#   volume_binding_mode = "Immediate"

#   parameters = {
#     mounter = "mountpoint"
#   }

#   depends_on = [aws_eks_node_group.eks_node_group]
# }
