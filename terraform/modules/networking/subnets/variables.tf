variable "vpc_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

variable "subnets" {
  description = <<-EOT
    Map of subnet name -> subnet definition. Add a new key here to create
    a new subnet - no module or root code change needed.

    type must be "public" or "private". route_table_id must be an existing
    route table's ID (this module never creates or modifies route tables -
    "public" subnets should point at a table that already routes to an IGW,
    "private" ones at a table that already routes to a NAT gateway).
  EOT
  type = map(object({
    cidr_block         = string
    availability_zone  = string
    type               = string # "public" | "private"
    route_table_id     = string
  }))

  validation {
    condition     = alltrue([for s in var.subnets : contains(["public", "private"], s.type)])
    error_message = "Each subnet's \"type\" must be exactly \"public\" or \"private\"."
  }
}
