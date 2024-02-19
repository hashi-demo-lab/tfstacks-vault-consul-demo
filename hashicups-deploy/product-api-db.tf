resource "kubernetes_service" "product-api-db" {
  metadata {
    name = "product-api-db"
    namespace = kubernetes_namespace.eks-hashicups-namespaces["products"].metadata[0].name
    labels = {
        app = "product-api-db"
    }
  }
  spec {
    selector = {
      app = "product-api-db"
    }
    port {
      port        = 5432
      target_port = 5432
    }
    type = "ClusterIP"
  }

}

resource "kubernetes_service_account" "product-api-db" {
  metadata {
    name = "product-api-db"
    namespace = kubernetes_namespace.eks-hashicups-namespaces["products"].metadata[0].name
  }
  automount_service_account_token = true

}

resource "kubernetes_deployment" "product-api-db" {
  metadata {
    name = "product-api-db"
    namespace = kubernetes_namespace.eks-hashicups-namespaces["products"].metadata[0].name
  }
  spec {
    replicas = 2

    selector {
      match_labels = {
        service = "product-api-db"
        app = "product-api-db"
      }
    }
    template {
      metadata {
        labels = {
          service = "product-api-db"
          app = "product-api-db"
        }
        annotations = {
          "consul.hashicorp.com/connect-inject" = true           
        }
      }
      spec {
        container {
          name  = "product-api-db"
          image = "hashicorpdemoapp/product-api-db:v0.0.22"
          port {
            container_port = 5432
          }
          env {
            name = "POSTGRES_DB"
            value = "products"
          }
          env {
            name = "POSTGRES_USER"
            value = "postgres"
          }
          env {
            name = "POSTGRES_PASSWORD"
            value = "password"
          }
          volume_mount {
            name = "pgdata"
            mount_path = "/var/lib/postgresql/data"
          }
        }
        service_account_name = "product-api-db"
        volume {
          name  = "pgdata"
          empty_dir {
          }
        }
      }
    }
  }
  wait_for_rollout = false

}

resource "consul_config_entry" "sd-product-api-db" {
  kind        = "service-defaults"
  name        = "product-api-db"
  namespace   = "products"

  config_json = jsonencode({
    Protocol    = "tcp"
    Expose      = {}
    MeshGateway = {}
    TransparentProxy = {}

  })

  depends_on = [
    time_sleep.wait_5_seconds
  ]
}

resource "consul_config_entry" "si-product-api-db" {
  name        = "product-api-db"
  kind        = "service-intentions"
  namespace   = "products"

  config_json = jsonencode({
    Sources = [
      {
        Namespace  = "products"
        Action     = "allow"
        Name       = "product-api"
        Partition  = "default"
        Precedence = 9
        Type       = "consul"
      }
    ]
  })

  depends_on = [
    time_sleep.wait_5_seconds
  ]
}