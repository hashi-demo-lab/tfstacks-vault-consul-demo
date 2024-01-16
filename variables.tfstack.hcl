variable "regions" {
  type = set(string)
}

variable "aws_identity_token_file" {
  type = string
}

variable "hcp_identity_token_file" {
  type = string
}

variable "k8s_identity_token_file" {
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

variable "consul_deployment_name" {
  type = string
  default = "tfstacks-consul"
}

variable "consul_tier" {
  type = string
  default = "development"
}

variable "consul_min_version" {
  type = string
  default = "1.16.4"
}

variable "cluster_name" {
  type = string
  default = "eks-cluster"
}

variable "namespace" {
  type = string
}

variable "tfc_hostname" {
  type = string
  default = "https://app.terraform.io"
}

variable "tfc_organization_name" {
  type = string
  default = "hashi-demos-apj"
}

variable "tfc_kubernetes_audience" {
  type = string
  default = "k8s.workload.identity"
}

# Consul Helm Chart

variable "consul_version" {
  type = string
}

variable "consul_helm_chart_version" {
  type = string
}


variable "aws_auth_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}