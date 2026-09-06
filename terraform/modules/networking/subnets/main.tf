##############################################################################
# Subnets, driven entirely by var.subnets - add a new key in tfvars and a
# new subnet gets created here automatically, no code change needed. Each
# subnet's route_table_id must point at an EXISTING route table (this
# module never creates, modifies, or re-points any IGW/NAT/route table).
##############################################################################

resource "aws_subnet" "workload_subnet" {
  for_each = var.subnets

  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.type == "public"

  tags = merge(
    var.common_tags,
    { Name = "${var.name_prefix}-${each.key}" },
    { "kubernetes.io/cluster/${var.cluster_name}" = "shared" },
    each.value.type == "public"
      ? { "kubernetes.io/role/elb" = "1" }
      : { "kubernetes.io/role/internal-elb" = "1" }
  )
}

resource "aws_route_table_association" "workload_subnet" {
  for_each = var.subnets

  subnet_id      = aws_subnet.workload_subnet[each.key].id
  route_table_id = each.value.route_table_id
}
