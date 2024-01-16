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


variable "replicas" {
  description = "Number of replicas"
  type        = number
}

variable "kubernetes_api_endpoint" {
  description = "Kubernetes api endpoint"
  type        = string
}