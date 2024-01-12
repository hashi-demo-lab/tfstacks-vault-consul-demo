resource "hcp_consul_cluster" "consul" {
  cluster_id          = "${var.deployment_name}-hcp"
  hvn_id              = var.hvn_id
  public_endpoint     = true
  tier                = var.tier
  min_consul_version  = var.min_version
}

resource "hcp_consul_cluster_root_token" "token" {
  cluster_id = hcp_consul_cluster.consul.id
}

data "hcp_consul_agent_kubernetes_secret" "consul" {
  cluster_id = hcp_consul_cluster.consul.cluster_id
}