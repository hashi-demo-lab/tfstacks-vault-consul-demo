resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx"
    namespace = kubernetes_namespace.eks-hashicups-namespaces["frontend"].metadata[0].name
    labels = {
        app = "nginx"
    }
  }
  spec {
    selector = {
      app = "nginx"
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_config_map" "nginx" {
  metadata {
    name = "nginx-config"
    namespace = kubernetes_namespace.eks-hashicups-namespaces["frontend"].metadata[0].name
  }

  data = {
    "nginx.conf" = "${file("${path.module}/config-maps/nginx-config.yml")}"
  }

  depends_on = [
    kubernetes_namespace.eks-hashicups-namespaces
  ]
}

resource "kubernetes_service_account" "nginx" {
  metadata {
    name = "nginx"
    namespace = kubernetes_namespace.eks-hashicups-namespaces["frontend"].metadata[0].name
  }
  automount_service_account_token = true

}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx"
    namespace = kubernetes_namespace.eks-hashicups-namespaces["frontend"].metadata[0].name
  }
  spec {
    replicas = 2

    selector {
      match_labels = {
        service = "nginx"
        app = "nginx"
      }
    }
    template {
      metadata {
        labels = {
          service = "nginx"
          app = "nginx"
        }
        annotations = {
          "consul.hashicorp.com/connect-inject" = true    
          "consul.hashicorp.com/connect-service-upstreams" = "frontend.svc.frontend.ns:3000, public-api.svc.frontend.ns:8081"
          
        }
      }
      spec {
        container {
          name  = "nginx"
          image = "nginx:stable-alpine"
          port {
            container_port = 80
          }
          volume_mount {
            name = "nginx-config"
            mount_path = "/etc/nginx"
          }
          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            failure_threshold     = 2
            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 1
          }
        }
        service_account_name = "nginx"
        volume {
          name  = "nginx-config"
          config_map {
            name = "nginx-config"
            items {
              key = "nginx.conf"
              path = "nginx.conf"
            }
          }
        }
      }
    }
  }
  wait_for_rollout = false

}

resource "consul_config_entry" "ig-nginx" {
  name        = "aws-default-ingress-gateway"
  kind        = "ingress-gateway"
  namespace   = "default"

  config_json = jsonencode({
    Listeners = [
      {
        Port     = 80
        Protocol = "http"
        Services = [
          { 
            Name      = "nginx"
            Namespace = "frontend" 
            Hosts     = ["*"]
          }
        ]
      }
    ]
  })

  depends_on = [
    time_sleep.wait_5_seconds
  ]
}

resource "consul_config_entry" "si-nginx" {
  name        = "nginx"
  kind        = "service-intentions"
  namespace   = "frontend"

  config_json = jsonencode({
    Sources = [
      {
        Namespace  = "default"
        Action     = "allow"
        Name       = "aws-default-ingress-gateway"
        Type       = "consul"
      }
    ]
  })

  depends_on = [
    time_sleep.wait_5_seconds
  ]
}

resource "consul_config_entry" "nginx_defaults" {
  name = "nginx"
  kind = "service-defaults"
  namespace = "frontend"

  config_json = jsonencode({
    Protocol = "http"
  })

  depends_on = [
    kubernetes_service.nginx
  ]
}