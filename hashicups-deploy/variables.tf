// hashicups config variables

variable "hashicups_config" {
  description = "Map of configuration variables"
  type        = map
  default     = {
    aws = {
      eks_namespaces = ["frontend", "products"]
    }
    gcp = {
      gke_namespaces = ["payments"]
    }
  }
}