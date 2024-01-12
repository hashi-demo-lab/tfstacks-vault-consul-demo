variable "deployment_name" {
  description = "Deployment name, used to prefix resources"
  type        = string
}

variable "hvn_id" {
  description = "HVN id"
  type        = string
}

variable "tier" {
  description = "Consul cluster tier"
  type        = string
}

variable "min_version" {
  description = "Consul minimum version"
  type        = string
}