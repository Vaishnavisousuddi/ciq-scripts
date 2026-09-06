##############################################################################
# EXISTING VPC - imported read-only via data source.
#
# This is a lookup, not a `terraform import`. Terraform never takes
# management ownership of dsa-gather-prod-vpc itself - it cannot modify or
# destroy it, no matter what this stack's state file contains. We only read
# its id/cidr_block to reference elsewhere.
##############################################################################

data "aws_vpc" "existing" {
  id = var.vpc_id
}

##############################################################################
# Secondary CIDR association - the ONE thing this module actually creates.
#
# This attaches 10.119.0.0/16 to the existing VPC as a second CIDR block.
# It does not touch the VPC's primary CIDR (10.118.0.0/16) or anything else
# already living in it. Subnet creation lives in the separate `subnets`
# module - this module's job stops at making the secondary range available
# to carve subnets out of.
##############################################################################

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = data.aws_vpc.existing.id
  cidr_block = var.secondary_cidr_block
}

##############################################################################
# ECR API endpoint - allow the new secondary CIDR through.
#
# If the existing ECR API interface endpoint has Private DNS enabled, it
# overrides api.ecr.<region>.amazonaws.com VPC-wide. Nodes in subnets carved
# out of the new secondary CIDR would resolve that hostname to the
# endpoint's ENI but get silently dropped on 443 without this rule - looks
# like a hang, not a clean refusal. This only ADDS an ingress rule to the
# existing endpoint SG; it does not create or replace the SG or the
# endpoint itself.
##############################################################################

resource "aws_security_group_rule" "allow_secondary_cidr_ecr_api" {
  count = var.ecr_api_endpoint_sg_id != "" ? 1 : 0

  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.secondary_cidr_block]
  security_group_id = var.ecr_api_endpoint_sg_id
  description       = "Allow CIQ secondary CIDR (10.119.0.0/16) to pull images from ECR via existing VPC endpoint"
}
