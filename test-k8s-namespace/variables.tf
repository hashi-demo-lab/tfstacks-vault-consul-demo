 
variable "cluster_name" {
  type    = string
}

/*
variable "cluster_endpoint" {
  type    = string
}

variable "oidc_provider_arn" {
  type    = string
  default = null
}

variable "cluster_certificate_authority_data" {
  type    = string
}

*/
variable "cluster_namespace" {
  type    = string
}

variable "eks_token" {
  type    = string
}