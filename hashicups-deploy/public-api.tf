resource "kubernetes_service" "public-api" {
  metadata {
    name = "public-api"
    namespace = "frontend"
    labels = {
        app = "public-api"
    }
  }
  spec {
    selector = {
      app = "public-api"
    }
    port {
      port        = 8080
      target_port = 8080
    }
    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_namespace.eks-hashicups-namespaces
  ]
}

resource "kubernetes_service_account" "public-api" {
  metadata {
    name = "public-api"
    namespace = "frontend"
  }
  automount_service_account_token = true

  depends_on = [
    kubernetes_namespace.eks-hashicups-namespaces
  ]
}

resource "kubernetes_deployment" "public-api" {
  metadata {
    name = "public-api"
    namespace = "frontend"
  }
  spec {
    replicas = 2

    selector {
      match_labels = {
        service = "public-api"
        app = "public-api"
      }
    }
    template {
      metadata {
        labels = {
          service = "public-api"
          app = "public-api"
        }
        annotations = {
          "consul.hashicorp.com/connect-inject" = true           
        }
      }
      spec {
        container {
          name  = "public-api"
          image = "hashicorpdemoapp/public-api:v0.0.7"
          port {
            container_port = 8080
          }
          env {
            name = "BIND_ADDRESS"
            value = ":8080"
          }
          env {
            name = "PRODUCT_API_URI"
            value = "http://product-api.virtual.products.ns.hashicups.ap.consul"
          }
          env {
            name = "PAYMENT_API_URI"
            value = "http://payments-api.virtual.payments.ns.hashicups.ap.aws-gcp-hashicups.peer.consul"
          }
          readiness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            failure_threshold     = 2
            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 1
          }
        }
        service_account_name = "public-api"
      }
    }
  }
  wait_for_rollout = false

  depends_on = [
    kubernetes_namespace.eks-hashicups-namespaces
  ]
}

resource "consul_config_entry" "si-public-api" {
  name        = "public-api"
  kind        = "service-intentions"
  partition   = "hashicups"
  namespace   = "frontend"

  config_json = jsonencode({
    Sources = [
      {
        Partition  = "hashicups"
        Namespace  = "frontend"
        Action     = "allow"
        Name       = "nginx"
        Type       = "consul"
      }
    ]
  })

  depends_on = [
    time_sleep.wait_5_seconds
  ]
}