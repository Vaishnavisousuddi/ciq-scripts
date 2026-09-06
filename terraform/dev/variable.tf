variable "region" {
  type    = string
  default = "us-west-2"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "common_tags" {
  type = map(string)
  default = {
    Terraformed = "True"
    Environment = "prod"
    Project     = "CIQ"
  }
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
}

########################################################################################################
# Existing dsa-gather-prod-vpc - looked up read-only in module "vpc"
# (modules/networking/vpc), never created or destroyed by this stack.
########################################################################################################

variable "dsa_gather_prod_vpc_id" {
  description = "ID of the existing dsa-gather-prod-vpc"
  type        = string
}

variable "secondary_cidr_block" {
  description = "Secondary IPv4 CIDR (10.119.0.0/16) to associate with dsa-gather-prod-vpc"
  type        = string
}

variable "ecr_api_endpoint_sg_id" {
  description = "Security group ID on the existing ECR API interface VPC endpoint (private DNS override) - gets an ingress rule for secondary_cidr_block on port 443. Leave \"\" to skip."
  type        = string
  default     = ""
}

########################################################################################################
# Subnets - map of name -> definition. Add a new key here to create a new
# subnet, no code or module change needed. route_table_id must point at an
# EXISTING route table (this stack never creates/modifies route tables,
# IGWs, or NAT gateways).
########################################################################################################

variable "subnets" {
  description = "Map of subnet name -> {cidr_block, availability_zone, type (\"public\"|\"private\"), route_table_id}"
  type = map(object({
    cidr_block        = string
    availability_zone = string
    type              = string
    route_table_id    = string
  }))
}

variable "cluster_subnet_names" {
  description = "Which keys from var.subnets the EKS control plane uses (must span >= 2 AZs)"
  type        = list(string)
}

variable "node_subnet_names" {
  description = "Which keys from var.subnets the main node group's nodes launch into"
  type        = list(string)
}

########################################################################################################
# EKS worker node group(s) - map of name -> definition, passed straight
# through to modules/eks. Add a new key here for another node group.
########################################################################################################

variable "worker_node_groups" {
  description = "Map of node group name -> node group definition"
  type = map(object({
    instance_types   = list(string)
    maximum_capacity = number
    minimum_capacity = number
    capacity_type    = string
    tags             = map(string)
    eks_ami_id       = string
    node_disk_size   = number
    volume_type      = string
  }))
}
variable "eks_admin_principal_arns" {
  type    = list(string)
  default = []
}

variable "state_bucket_name" {
  type = string
}
variable "lock_table_name" {
  type = string
}
variable "create_oidc_provider" {
  type    = bool
  default = true
}
variable "github_actions_role_name" {
  type = string
}
variable "github_org" {
  type = string
}
variable "github_repo" {
  type = string
}