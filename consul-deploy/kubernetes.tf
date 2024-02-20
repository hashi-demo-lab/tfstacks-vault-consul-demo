
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

resource "kubernetes_manifest" "consul_reference_grant" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1alpha2"
    kind       = "ReferenceGrant"
    metadata = {
      name      = "consul-reference-grant"
      namespace = "default"
    }
    spec = {
      from = [
        {
          group     = "gateway.networking.k8s.io"
          kind      = "HTTPRoute"
          namespace = "consul"
        },
      ]
      to = [
        {
          group = ""
          kind  = "Service"
        },
      ]
    }
  }
}

resource "kubernetes_cluster_role_binding" "consul_auth_binding" {
  metadata {
    name      = "consul-auth-binding"
    namespace = "consul"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "consul-api-gateway-auth"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "consul-server"
    namespace = "consul"
  }
}

resource "kubernetes_cluster_role_binding" "consul_api_gateway_tokenreview_binding" {
  metadata {
    name      = "consul-api-gateway-tokenreview-binding"
    namespace = "consul"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "consul-api-gateway"
    namespace = "consul"
  }
}

resource "kubernetes_cluster_role" "consul_api_gateway_auth" {
  metadata {
    name      = "consul-api-gateway-auth"
    namespace = "consul"
  }
  rule {
    api_groups = [""]
    resources  = ["serviceaccounts"]
    verbs      = ["get"]
  }
}

resource "kubernetes_cluster_role_binding" "consul_api_gateway_auth_binding" {
  metadata {
    name      = "consul-api-gateway-auth-binding"
    namespace = "consul"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "consul-api-gateway-auth"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "consul-api-gateway"
    namespace = "consul"
  }
}
