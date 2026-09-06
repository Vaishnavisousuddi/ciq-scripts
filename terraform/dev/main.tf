########################################################################################################
# Existing VPC import + secondary CIDR attachment ONLY.
# No subnets, no route tables, no IGW/NAT touched here - see module "subnets" below.
########################################################################################################

module "vpc" {
  source = "../modules/networking/vpc"

  vpc_id                 = var.dsa_gather_prod_vpc_id
  secondary_cidr_block   = var.secondary_cidr_block
  ecr_api_endpoint_sg_id = var.ecr_api_endpoint_sg_id
}

########################################################################################################
# Subnets - fully driven by var.subnets. Add a new key to that map in
# tfvars and a new subnet gets created here, no code change needed.
# depends_on forces the secondary CIDR to be attached before any subnet is
# carved out of it - subnet cidr_block values only become valid afterward.
########################################################################################################

module "subnets" {
  source = "../modules/networking/subnets"

  vpc_id       = module.vpc.vpc_id
  cluster_name = var.cluster_name
  name_prefix  = var.name_prefix
  common_tags  = var.common_tags
  subnets      = var.subnets

  depends_on = [module.vpc]
}

########################################################################################################
# EKS cluster (control plane) + node group(s). worker_node_groups is a map -
# add a new key in tfvars for another node group, no code change needed.
# depends_on is explicit here (in addition to the implicit dependency
# already created by referencing module.subnets.subnet_ids below) so the
# ordering stays correct even if a future edit ever removes that reference.
########################################################################################################

module "eks" {
  source = "../modules/eks"

  cluster_name       = var.cluster_name
  name_prefix        = var.name_prefix
  vpc_id             = module.vpc.vpc_id
  cluster_subnet_ids = [for name in var.cluster_subnet_names : module.subnets.subnet_ids[name]]
  node_subnet_ids    = [for name in var.node_subnet_names : module.subnets.subnet_ids[name]]
  kubernetes_version = var.kubernetes_version
  eks_admin_principal_arns = var.eks_admin_principal_arns

  worker_node_groups = var.worker_node_groups

  environment = var.environment
  common_tags = var.common_tags

  depends_on = [module.vpc, module.subnets]
}
