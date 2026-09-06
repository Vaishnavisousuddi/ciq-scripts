##############################################################################
# One managed node group per key in var.worker_node_groups - for_each keyed
# by name (not count/index), so adding, removing, or reordering entries in
# tfvars never causes an unrelated node group to be destroyed/recreated
# (a classic count-based-list pitfall: removing item 1 of 3 shifts item 2
# into index 1, and Terraform sees that as "index 1 changed" and replaces
# it even though nothing about it actually changed).
##############################################################################

resource "aws_launch_template" "node_group" {
  for_each = var.worker_node_groups

  name     = "${each.key}-lt"
  image_id = each.value.eks_ami_id

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = each.value.node_disk_size
      volume_type = each.value.volume_type
      encrypted   = true
    }
  }

  instance_type = each.value.instance_types[0]

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.eks_nodes_sg.id]
    delete_on_termination       = true
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.common_tags,
      each.value.tags,
      { "kubernetes.io/cluster/${var.cluster_name}" = "owned" }
    )
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    cat <<'YAML' > /etc/nodeadm.yaml
    apiVersion: node.eks.aws/v1alpha1
    kind: NodeConfig
    spec:
      cluster:
        name: ${aws_eks_cluster.eks_cluster.name}
        apiServerEndpoint: ${aws_eks_cluster.eks_cluster.endpoint}
        certificateAuthority: ${aws_eks_cluster.eks_cluster.certificate_authority[0].data}
        cidr: ${aws_eks_cluster.eks_cluster.kubernetes_network_config[0].service_ipv4_cidr}
    YAML

    nodeadm init --config-source file:///etc/nodeadm.yaml
  EOF
  )
}

resource "aws_eks_node_group" "node_group" {
  for_each = var.worker_node_groups

  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.node_subnet_ids
  capacity_type   = each.value.capacity_type

  scaling_config {
    desired_size = each.value.minimum_capacity
    max_size     = each.value.maximum_capacity
    min_size     = each.value.minimum_capacity
  }

  launch_template {
    id      = aws_launch_template.node_group[each.key].id
    version = aws_launch_template.node_group[each.key].latest_version
  }

  tags = merge(var.common_tags, each.value.tags)

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.kube_proxy,
  ]
}
