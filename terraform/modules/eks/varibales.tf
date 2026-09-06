variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where EKS will be created"
  type        = string
}

variable "cluster_subnet_ids" {
  description = "Subnet IDs passed directly to the EKS control plane's vpc_config.subnet_ids. Caller decides exactly what goes here (must span >=2 AZs, per AWS's requirement) - decoupled from node placement."
  type        = list(string)
}

variable "node_subnet_ids" {
  description = "Subnet IDs used by the managed node group(s) in worker_node_groups. Independent of cluster_subnet_ids - a node group's subnets don't have to match (or even overlap) the control plane's."
  type        = list(string)
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
}

variable "worker_node_groups" {
  description = "Map of node group name -> node group definition. Add a new key here to create a new managed node group - no module code change needed."
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

variable "environment" {
  description = "Environment name"
  type        = string
  
}

variable "common_tags" {
  type        = map(string)
  default     = {}
}

variable "eks_admin_principal_arns" {
  description = "Additional IAM principal ARNs (users or roles) to grant cluster-admin EKS access entries to, beyond whoever is currently running Terraform. Add an ARN here in tfvars to grant someone else access - no code change needed."
  type        = list(string)
  default     = []
}