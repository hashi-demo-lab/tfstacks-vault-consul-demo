resource "kubernetes_service" "payments-api" {
  metadata {
    name = "payments-api"
    namespace = kubernetes_namespace.eks-hashicups-namespaces["payments"].metadata[0].name
    labels = {
        app = "payments-api"
    }
  }
  spec {
    selector = {
      app = "payments-api"
    }
    port {
      port        = 8080
      target_port = 8080
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_config_map" "payments-api" {
  metadata {
    name = "payments-api-config"
    namespace = kubernetes_namespace.eks-hashicups-namespaces["payments"].metadata[0].name
  }

  data = {
    "payments-api.conf" = "${file("${path.module}/config-maps/payments-api-config.yml")}"
  }


}

resource "kubernetes_service_account" "payments-api" {
  metadata {
    name = "payments-api"
    namespace = kubernetes_namespace.eks-hashicups-namespaces["payments"].metadata[0].name
  }
  automount_service_account_token = true

}

resource "kubernetes_deployment" "payments-api" {
  metadata {
    name = "payments-api"
    namespace = kubernetes_namespace.eks-hashicups-namespaces["payments"].metadata[0].name
  }
  spec {
    replicas = 2

    selector {
      match_labels = {
        service = "payments-api"
        app = "payments-api"
      }
    }
    template {
      metadata {
        labels = {
          service = "payments-api"
          app = "payments-api"
        }
        annotations = {
          "consul.hashicorp.com/connect-inject" = true  
        }
      }
      spec {
        container {
          name  = "payments-api"
          image = "hashicorpdemoapp/payments:v0.0.16"
          port {
            container_port = 8080
          }
          volume_mount {
            name = "payments-api-config"
            mount_path = "/config/application.properties"
            sub_path = "payments-api.conf"
          }
          readiness_probe {
            http_get {
              path = "/actuator/health"
              port = 8080
            }
            failure_threshold     = 2
            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 1
          }
        }
        service_account_name = "payments-api"
        volume {
          name  = "payments-api-config"
          config_map {
            name = "payments-api-config"
            items {
              key = "payments-api.conf"
              path = "payments-api.conf"
            }
          }
        }
      }
    }
  }
  wait_for_rollout = false
  

}

resource "consul_config_entry" "si-payments-api" {
  name        = "payments-api"
  kind        = "service-intentions"
  namespace   = "payments"

  config_json = jsonencode({
    Sources = [
      {
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