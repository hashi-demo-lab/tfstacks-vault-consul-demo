// create kubernetes resources on hashicups eks cluster
resource "kubernetes_namespace" "eks-hashicups-namespaces" {
  for_each = var.hashicups_namespace

  metadata {
    name = each.key
  }
}

resource "consul_config_entry" "eks-proxy_defaults" {
  kind        = "proxy-defaults"
  name        = "global"

  config_json = jsonencode({
    Config = {
      Protocol = "http"
    }
  })
}

resource "time_sleep" "wait_5_seconds" {
  create_duration = "5s"

  depends_on = [
    kubernetes_deployment.nginx,
    kubernetes_deployment.frontend,
    kubernetes_deployment.public-api,
    kubernetes_deployment.product-api,
    kubernetes_deployment.product-api-db,
    kubernetes_deployment.payments-api
  ]
}