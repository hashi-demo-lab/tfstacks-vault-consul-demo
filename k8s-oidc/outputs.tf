output "oidc_binding_uid" {
  value = kubernetes_cluster_role_binding_v1.oidc_role.uid
}