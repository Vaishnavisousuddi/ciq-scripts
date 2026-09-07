region      = "us-west-2"
environment = "poc-test"
name_prefix = "ciq-poc-prod-mirror"

common_tags = {
  Terraformed = "True"
  Environment = "poc-test"
  Project     = "CIQ"
}

# POC mirror VPC (built via mirror-vpc.sh) - primary CIDR is 10.222.0.0/16 -
# NOT real production. This is a different AWS account (804540873012,
# hackathon) 
dsa_gather_prod_vpc_id = "vpc-00f0170a867adaf37"
secondary_cidr_block   = "10.223.0.0/16"

# ECR endpoint SG - value provided, carried over as-is (see note above)
# ecr_api_endpoint_sg_id = "sg-0435214819864879a"
ecr_api_endpoint_sg_id = ""

# All 9 subnets, in the current subnets-map shape. route_table_id/type set
# explicitly per subnet (no longer inferred by the module).
subnets = {
  "web-crawler-public-subnet-az1" = {
    cidr_block        = "10.223.0.0/19"
    availability_zone = "us-west-2a"
    type              = "public"
    route_table_id    = "rtb-0fe35d44f1bc21387"
  }
  "browserfarm-public-subnet-az1" = {
    cidr_block        = "10.223.32.0/19"
    availability_zone = "us-west-2a"
    type              = "public"
    route_table_id    = "rtb-0fe35d44f1bc21387"
  }
  "common-public-subnet-az1" = {
    cidr_block        = "10.223.64.0/19"
    availability_zone = "us-west-2a"
    type              = "public"
    route_table_id    = "rtb-0fe35d44f1bc21387"
  }
  "browserfarm-public-subnet-az3" = {
    cidr_block        = "10.223.96.0/19"
    availability_zone = "us-west-2c"
    type              = "public"
    route_table_id    = "rtb-0fe35d44f1bc21387"
  }
  "common-public-subnet-az3" = {
    cidr_block        = "10.223.128.0/19"
    availability_zone = "us-west-2c"
    type              = "public"
    route_table_id    = "rtb-0fe35d44f1bc21387"
  }
  "web-crawler-private-subnet-az1" = {
    cidr_block        = "10.223.160.0/20"
    availability_zone = "us-west-2a"
    type              = "private"
    route_table_id    = "rtb-090c3e1867facd245"
  }
  "browserfarm-private-subnet-az1" = {
    cidr_block        = "10.223.176.0/20"
    availability_zone = "us-west-2a"
    type              = "private"
    route_table_id    = "rtb-090c3e1867facd245"
  }
  "common-private-subnet-az3" = {
    cidr_block        = "10.223.192.0/20"
    availability_zone = "us-west-2c"
    type              = "private"
    route_table_id    = "rtb-0769fb1deda8a6473"
  }
  "browserfarm-private-subnet-az3" = {
    cidr_block        = "10.223.208.0/20"
    availability_zone = "us-west-2c"
    type              = "private"
    route_table_id    = "rtb-0769fb1deda8a6473"
  }
}

# Node group launches into the 3 public AZ1 subnets
node_subnet_names = [
  "web-crawler-public-subnet-az1",
  "browserfarm-public-subnet-az1",
  "common-public-subnet-az1",
]

# EKS control plane spans all 4 private subnets (>= 2 AZs required)
cluster_subnet_names = [
  "web-crawler-private-subnet-az1",
  "browserfarm-private-subnet-az1",
  "common-private-subnet-az3",
  "browserfarm-private-subnet-az3",
]

cluster_name       = "dsa-gather-prod-cluster"
kubernetes_version = "1.35"

worker_node_groups = {
  "common-nodegroup" = {
    instance_types   = ["t3.medium"]
    maximum_capacity = 2
    minimum_capacity = 1
    capacity_type    = "ON_DEMAND"
    tags             = {}
    eks_ami_id       = "ami-06e105010aa29bfd2"
    node_disk_size   = 20
    volume_type      = "gp3"
  }
  "common-2" = {
    instance_types   = ["t3.medium"]
    maximum_capacity = 2
    minimum_capacity = 1
    capacity_type    = "ON_DEMAND"
    tags             = {}
    eks_ami_id       = "ami-06e105010aa29bfd2"
    node_disk_size   = 20
    volume_type      = "gp3"
  }
}
# eks_admin_principal_arns = []
eks_admin_principal_arns = [
  "arn:aws:iam::804540873012:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_AWSAdministratorAccess_8f72fcb330822dc3",
  "arn:aws:iam::804540873012:role/ciq-github-actions-terraform",
]

state_bucket_name = "ciq-terraform-state-804540873012"
lock_table_name          = "ciq-terraform-locks"
create_oidc_provider     = true
github_actions_role_name = "ciq-github-actions-terraform"
github_org               = "Vaishnavisousuddi"
github_repo              = "ciq-scripts"

github_owner_id = "184361237"
github_repo_id  = "1358707010"