variable "region" {
  description = "HCP HVN region"
  type        = string
  default     = "ap-southeast-1"
}

variable "hcp_project_id" {
  description = "HCP Project ID"
  type        = string
  default     = "b1b0b041-fc8d-4d11-9929-8a225d1e3ee6"
}

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