variable "regions" {
  type = set(string)
}

variable "aws_identity_token_file" {
  type = string
}

variable "hcp_identity_token_file" {
  type = string
}

variable "workload_idp_name" {
  type = string
  default = "tfstacks-workload-identity-provider"
}

variable "hcp_region" {
  type = string
}

variable "hcp_project_id" {
  type = string
}

variable "role_arn" {
  type = string
}

variable "vpc_name" {
  type = string 
}

variable "vpc_cidr" {
  type = string
}

variable "kubernetes_version" {
  type = string
  default = "1.28"
}

variable "deployment_id" {
  type = string
  default = "hvn-tfstacks"
}

variable "hvn_cidr" {
  type = string
}

variable "aws_vpc_cidr" {
  type = string
}

