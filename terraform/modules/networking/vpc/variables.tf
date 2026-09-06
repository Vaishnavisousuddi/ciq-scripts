variable "vpc_id" {
  description = "ID of the existing VPC to import (read-only) - dsa-gather-prod-vpc"
  type        = string
}

variable "secondary_cidr_block" {
  description = "Secondary IPv4 CIDR to associate with the existing VPC (10.119.0.0/16)"
  type        = string
}

variable "ecr_api_endpoint_sg_id" {
  description = "Security group ID on the VPC's existing ECR API interface endpoint. Leave empty (\"\") to skip the ingress rule."
  type        = string
  default     = ""
}
