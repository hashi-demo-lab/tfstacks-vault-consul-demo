output "root_token" {
  value     = hcp_consul_cluster_root_token.token.secret_id
  sensitive = true
}

output "bootstrap_token" {
  value = base64decode(yamldecode(hcp_consul_cluster_root_token.token.kubernetes_secret).data.token)
}

output "gossip_encrypt_key" {
  value = base64decode(yamldecode(data.hcp_consul_agent_kubernetes_secret.consul.secret).data.gossipEncryptionKey)
}

output "client_ca_cert" {
  value = base64decode(yamldecode(data.hcp_consul_agent_kubernetes_secret.consul.secret).data.caCert)
}

output "public_endpoint_url" {
  value = hcp_consul_cluster.consul.consul_public_endpoint_url
}

output "private_endpoint_url" {
  value = hcp_consul_cluster.consul.consul_private_endpoint_url
}