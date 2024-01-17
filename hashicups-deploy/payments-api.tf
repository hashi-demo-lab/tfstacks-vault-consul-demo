resource "local_file" "payments-api-config" {
  content = templatefile("../../../examples/templates/payments-api-config.yml", {
    jaeger_collector_fqdn = ""
    })
  filename = "${path.module}/config-maps/payments-api-config.yml.tmp"
}

resource "kubernetes_service" "payments-api" {
  metadata {
    name = "payments-api"
    namespace = "payments"
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

  depends_on = [
    kubernetes_namespace.eks-hashicups-namespaces
  ]
}

resource "kubernetes_config_map" "payments-api" {
  metadata {
    name = "payments-api-config"
    namespace = "payments"
  }

  data = {
    "payments-api.conf" = local_file.payments-api-config.content
  }

  depends_on = [
    kubernetes_namespace.eks-hashicups-namespaces
  ]
}

resource "kubernetes_service_account" "payments-api" {
  metadata {
    name = "payments-api"
    namespace = "payments"
  }
  automount_service_account_token = true

  depends_on = [
    kubernetes_namespace.eks-hashicups-namespaces
  ]
}

resource "kubernetes_deployment" "payments-api" {
  metadata {
    name = "payments-api"
    namespace = "payments"
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
  
  depends_on = [
    kubernetes_namespace.eks-hashicups-namespaces
  ]
}

resource "consul_config_entry" "ep-payments-api" {
  name = "hashicups"
  kind = "exported-services"
  partition   = "hashicups"

  config_json = jsonencode({
    Services = [
      {
        Name = "payments-api"
        Namespace = "payments"
        Consumers = [
          {
            Peer = "aws-gcp-hashicups"
          }
        ]
      }
    ]
  })
}

resource "consul_config_entry" "si-payments-api" {
  name        = "payments-api"
  kind        = "service-intentions"
  partition   = "hashicups"
  namespace   = "payments"

  config_json = jsonencode({
    Sources = [
      {
        Namespace  = "frontend"
        Action     = "allow"
        Name       = "public-api"
        Type       = "consul"
        Peer       = "aws-gcp-hashicups"
      }
    ]
  })

  depends_on = [
    time_sleep.wait_5_seconds
  ]
}