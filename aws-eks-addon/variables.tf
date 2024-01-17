
variable "vpc_id" {
  type    = string
  default = "vpc-0ca02263a9d1dde5d"
}

variable "region" {
  type    = string
  default = "ap-southeast-2"
}

variable "cluster_name" {
  type    = string
  default = "eks-cluster"
}

variable "cluster_endpoint" {
  type    = string
}

variable "cluster_version" {
  type    = string
  default = "1.27"
}

variable "oidc_provider_arn" {
  type    = string
}

variable "cluster_certificate_authority_data" {
  type    = string
}