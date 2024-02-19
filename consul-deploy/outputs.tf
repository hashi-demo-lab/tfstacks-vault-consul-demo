/* output "ingress_public_fqdn" {
  description = "Ingress gateway public fqdn"
  value       = data.kubernetes_service.consul-ingress-gateway.status.0.load_balancer.0.ingress.0.hostname
} */

output "consul_namespace" {
  description = "value of consul namespace"
  value       = kubernetes_namespace.consul.metadata.0.name
}