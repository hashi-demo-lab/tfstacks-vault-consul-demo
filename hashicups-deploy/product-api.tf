resource "kubernetes_service" "product-api" {
  metadata {
    name = "product-api"
    namespace = "products"
    labels = {
        app = "product-api"
    }
  }
  spec {
    selector = {
      app = "product-api"
    }
    port {
      port        = 9090
      target_port = 9090
    }
    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_namespace.eks-hashicups-namespaces
  ]
}

resource "kubernetes_config_map" "product-api" {
  metadata {
    name = "product-api-config"
    namespace = "products"
  }

  data = {
    "product-api.conf" = "${file("${path.module}/config-maps/product-api-config.yml")}"
  }

  depends_on = [
    kubernetes_namespace.eks-hashicups-namespaces
  ]
}

resource "kubernetes_service_account" "product-api" {
  metadata {
    name = "product-api"
    namespace = "products"
  }
  automount_service_account_token = true

  depends_on = [
    kubernetes_namespace.eks-hashicups-namespaces
  ]
}

resource "kubernetes_deployment" "product-api" {
  metadata {
    name = "product-api"
    namespace = "products"
  }
  spec {
    replicas = 2

    selector {
      match_labels = {
        service = "product-api"
        app = "product-api"
      }
    }
    template {
      metadata {
        labels = {
          service = "product-api"
          app = "product-api"
        }
        annotations = {
          "consul.hashicorp.com/connect-inject" = true           
        }
      }
      spec {
        container {
          name  = "product-api"
          image = "hashicorpdemoapp/product-api:v0.0.22"

          port {
            container_port = 9090
          }
          env {
            name = "CONFIG_FILE"
            value = "/config/product-api.conf"
          }
          volume_mount {
            name = "product-api-config"
            mount_path = "/config"
          }
          readiness_probe {
            http_get {
              path = "/health"
              port = 9090
            }
            failure_threshold     = 2
            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 1
          }
        }
        service_account_name = "product-api"
        volume {
          name  = "product-api-config"
          config_map {
            name = "product-api-config"
            items {
              key = "product-api.conf"
              path = "product-api.conf"
            }
          }
        }
      }
    }
  }
  wait_for_rollout = false
  
  depends_on = [
    kubernetes_namespace.eks-hashicups-namespaces
  ]
}

resource "consul_config_entry" "si-product-api" {
  name        = "product-api"
  kind        = "service-intentions"
  partition   = "hashicups"
  namespace   = "products"

  config_json = jsonencode({
    Sources = [
      {
        Partition  = "hashicups"
        Namespace  = "frontend"
        Action     = "allow"
        Name       = "public-api"
        Type       = "consul"
      }
    ]
  })

  depends_on = [
    time_sleep.wait_5_seconds
  ]
}