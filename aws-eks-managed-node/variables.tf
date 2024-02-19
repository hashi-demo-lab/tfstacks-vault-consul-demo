variable "region" {
  type    = string
  default = "ap-southeast-2"
}

variable "cluster_name" {
  type    = string
  default = "eks-dev"
}

variable "private_subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = "1.28"
}

variable "tfc_hostname" {
  type    = string
  default = "https://app.terraform.io"
}

variable "tfc_kubernetes_audience" {
  type = string
}

variable "eks_clusteradmin_arn" {
  type = string
}

variable "eks_clusteradmin_username" {
  type = string
}

variable "vpc_security_group_ids" {
  type = string

}