
# odic-identity pre-requisite
resource "kubernetes_cluster_role_binding_v1" "oidc_role" {
  metadata {
    name = "odic-identity"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = var.tfc_organization_name
  }
}


resource "kubernetes_namespace_v1" "example" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = var.cluster_namespace
  }
}