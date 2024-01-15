variable "hcp_region" {
  description = "HCP HVN region"
  type        = string
  default     = "ap-southeast-1"
}

/* variable "hcp_project_id" {
  description = "HCP Project ID"
  type        = string
}  */

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-0a078d2d1ab32ad27"
}

variable "private_subnets" {
  description = "Private subnets"
  type        = list(string)
  default = [ "subnet-0306e705f62f67993" ]
}

variable "route_table_id" {
  description = "AWS Route table ID"
  type        = string
}

variable "deployment_id" {
  description = "Deployment id"
  type        = string
  default = "hvn-tfstacks"
}

variable "hvn_cidr" {
  description = "HCP HVN cidr"
  type        = string
  default = "172.31.0.0/16"
}

variable "aws_vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default = "10.0.0.0/16"
}