resource "kubernetes_service" "public-api" {
  metadata {
    name = "public-api"
    namespace = kubernetes_namespace.eks-hashicups-namespaces["frontend"].metadata[0].name
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

}

resource "kubernetes_service_account" "public-api" {
  metadata {
    name = "public-api"
    namespace = kubernetes_namespace.eks-hashicups-namespaces["frontend"].metadata[0].name
  }
  automount_service_account_token = true

}

resource "kubernetes_deployment" "public-api" {
  metadata {
    name = "public-api"
    namespace = kubernetes_namespace.eks-hashicups-namespaces["frontend"].metadata[0].name
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
          "consul.hashicorp.com/connect-service-upstreams" = "product-api.svc.products.ns:9090, payments-api.svc.payments.ns:8080"
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
            value = "http://localhost:9090"
          }
          env {
            name = "PAYMENT_API_URI"
            value = "http://localhost:8080"
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

}

resource "consul_config_entry" "si-public-api" {
  name        = "public-api"
  kind        = "service-intentions"
  namespace   = "frontend"

  config_json = jsonencode({
    Sources = [
      {
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