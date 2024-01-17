// hashicups config variables

variable "hashicups_namspace" {
  description = "Hashicups namespace"
  type        =  set(string)
  default     = ["frontend", "products", "payments"]
}
  
variable "ingress_public_fqdn" {
  description = "Public EKS Consul FQDN for ingress"
  type        = string
}