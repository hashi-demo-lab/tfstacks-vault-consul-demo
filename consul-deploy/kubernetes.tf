/* 
data "kubernetes_service" "consul-ingress-gateway" {
  metadata {
    name = "consul-aws-default-ingress-gateway"
    namespace = "consul"
  }

  depends_on = [
    helm_release.consul-client
  ]
}
*/

resource "kubernetes_namespace" "consul" {
  metadata {
    name = "consul"
  }
}

resource "kubernetes_secret_v1" "consul-bootstrap-token" {
  metadata {
    name      = "${var.deployment_name}-hcp-bootstrap-token"
    namespace = "consul"
  }

  data = {
    token = var.bootstrap_token
  }
}

resource "kubernetes_secret" "consul-client-secrets" {
  metadata {
    name      = "${var.deployment_name}-hcp-client-secrets"
    namespace = "consul"
  }

  data = {
    gossipEncryptionKey = var.gossip_encrypt_key
    caCert              = var.client_ca_cert
  }
}

resource "kubernetes_manifest" "api_gateway" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1beta1"
    kind       = "Gateway"
    metadata = {
      name      = "api-gateway"
      namespace = kubernetes_namespace.consul.metadata.0.name
    }
    spec = {
      gatewayClassName = "consul"
      listeners = [
        {
          protocol = "HTTP"
          port     = 80
          name     = "http"
          allowedRoutes = {
            namespaces = {
              from = "All"
            }
          }
        },
      ]
    }
  }
}