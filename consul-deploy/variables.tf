variable "deployment_name" {
  description = "Deployment name, used to prefix resources"
  type        = string
}

variable "helm_chart_version" {
  type        = string
  description = "Helm chart version"
}

variable "consul_version" {
  description = "Consul version"
  type        = string
}

variable "private_endpoint_url" {
  description = "Private endpoint url"
  type        = string
}

variable "bootstrap_token" {
  description = "ACL bootstrap token"
  type        = string
}

variable "gossip_encrypt_key" {
  description = "Gossip encryption key"
  type        = string
}

variable "client_ca_cert" {
  description = "Client ca certificate"
  type        = string
}

variable "replicas" {
  description = "Number of replicas"
  type        = number
}

variable "kubernetes_api_endpoint" {
  description = "Kubernetes api endpoint"
  type        = string
}