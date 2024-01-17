resource "local_file" "eks-client-default-partition-helm-values" {
  content = templatefile("${path.module}/templates/hcp-consul-client-partition-helm.yml", {
    partition_name                = "default"
    deployment_name               = "${var.deployment_name}-hcp"
    consul_version                = var.consul_version
    external_server_private_fqdn  = trimprefix(var.private_endpoint_url, "https://")
    external_server_https_port    = 443
    kubernetes_api_endpoint       = var.kubernetes_api_endpoint
    replicas                      = var.replicas
    cloud                         = "aws"
    })
  filename = "eks-client-default-partition-helm-values.yml.tmp"
}

# consul client
resource "helm_release" "consul-client" {
  name          = "${var.deployment_name}-consul-client"
  chart         = "consul"
  repository    = "https://helm.releases.hashicorp.com"
  version       = var.helm_chart_version
  namespace     = "consul"
  timeout       = "300"
  wait          = true
  values        = [
    local_file.eks-client-default-partition-helm-values.content
  ]

  depends_on    = [
    kubernetes_namespace.consul
  ]
}