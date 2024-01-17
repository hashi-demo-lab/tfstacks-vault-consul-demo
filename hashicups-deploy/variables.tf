// hashicups config variables

variable "hashicups_config" {
  description = "Map of configuration variables"
  type        = map
  default     = {
    aws = {
      eks_namespaces = ["frontend", "products", "payments"]
    }
  }
}

variable "ingress_public_fqdn" {
  description = "Public EKS Consul FQDN for ingress"
  type        = string
}