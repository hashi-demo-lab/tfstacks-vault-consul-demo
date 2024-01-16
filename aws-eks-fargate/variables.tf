variable "region" {
  type    = string
  default = "ap-southeast-2"
}

variable "cluster_name" {
  type    = string
  default = "eks-cluster"
}

variable "private_subnets" {
  type = list(string)
}

variable "vpc_id" {
  type    = string
}

variable "kubernetes_version" {
  type    = string
  default = "1.27"  
}

variable "aws_auth_roles" {
  type = list(object({
    role_arn = string
    username = string
    groups   = list(string)
  }))
  default = []
}