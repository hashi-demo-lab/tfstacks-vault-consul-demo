#AWS VPC
component "vpc" {
  for_each = var.regions

  source = "./aws-vpc"

  inputs = {
    vpc_name = var.vpc_name
    vpc_cidr = var.vpc_cidr
  }

  providers = {
    aws     = provider.aws.configurations[each.value]
  }
} 

#AWS EKS
component "eks" {
  for_each = var.regions

  source = "./aws-eks-managed-node"

  inputs = {
    vpc_id = component.vpc[each.value].vpc_id
    private_subnets = component.vpc[each.value].private_subnets
    kubernetes_version = var.kubernetes_version
    cluster_name = var.cluster_name
    tfc_hostname = var.tfc_hostname
    tfc_kubernetes_audience = var.tfc_kubernetes_audience
    eks_clusteradmin_arn = var.eks_clusteradmin_arn
    eks_clusteradmin_username = var.eks_clusteradmin_username
  }

  providers = {
    aws    = provider.aws.configurations[each.value]
    cloudinit = provider.cloudinit.this
    kubernetes  = provider.kubernetes.this
    time = provider.time.this
    tls = provider.tls.this
  }
}

# Update K8s role-binding
component "k8s-rbac" {
  for_each = var.regions

  source = "./k8s-rbac"

  inputs = {
    cluster_endpoint = component.eks[each.value].cluster_endpoint
    tfc_organization_name = var.tfc_organization_name
  }

  providers = {
    kubernetes  = provider.kubernetes.configurations[each.value]
  }
}


# K8s Addons - aws load balancer controller, coredns, vpc-cni, kube-proxy
component "k8s-addons" {
  for_each = var.regions

  source = "./aws-eks-addon"

  inputs = {
    cluster_name = component.eks[each.value].cluster_name
    vpc_id = component.vpc[each.value].vpc_id
    private_subnets = component.vpc[each.value].private_subnets
    cluster_endpoint = component.eks[each.value].cluster_endpoint
    cluster_version = component.eks[each.value].cluster_version
    oidc_provider_arn = component.eks[each.value].oidc_provider_arn
    cluster_certificate_authority_data = component.eks[each.value].cluster_certificate_authority_data
    oidc_binding_id = component.k8s-rbac[each.value].oidc_binding_id
  }

  providers = {
    kubernetes  = provider.kubernetes.oidc_configurations[each.value]
    helm  = provider.helm.oidc_configurations[each.value]
    aws    = provider.aws.configurations[each.value]
    time = provider.time.this
  }
}

# Namespace
component "k8s-namespace" {
  for_each = var.regions

  source = "./k8s-namespace"

  inputs = {
    namespace = var.namespace
    labels = component.k8s-addons[each.value].eks_addons
  }

  providers = {
    kubernetes  = provider.kubernetes.oidc_configurations[each.value]
  }
}

# HCP HVN and AWS Transit Gateway
component "hcphvn" {

  source = "./hcp-hvn-transit"

  inputs = {
    hcp_project_id = var.hcp_project_id
    hcp_region = var.hcp_region
    #need to handle multiple vpc's
    vpc_id = component.vpc[var.hcp_region].vpc_id
    private_subnets = component.vpc[var.hcp_region].private_subnets
    route_table_id = component.vpc[var.hcp_region].route_table_id[0]
    deployment_id = var.deployment_id
    hvn_cidr = var.hvn_cidr

    #need to handle multiple vpc's
    aws_vpc_cidr = var.vpc_cidr
  }

  providers = {
    aws    = provider.aws.configurations[var.hcp_region]
    hcp    = provider.hcp.configuration
  }

}

# HCP CONSUL Component
component "hcp-consul" {

  source = "./hcp-consul"

  inputs = {
    deployment_name = var.consul_deployment_name
    hvn_id = component.hcphvn.hvn_id
    tier = var.consul_tier
    min_version = var.consul_min_version
  }

  providers = {
    hcp    = provider.hcp.configuration
  }

}


# Helm Install Consul
component "consul-deploy" {
  for_each = var.regions

  source = "./consul-deploy"

  inputs = {
      deployment_name = var.consul_deployment_name
      helm_chart_version = var.consul_helm_chart_version
      consul_version = var.consul_min_version
      kubernetes_api_endpoint = component.eks[each.value].cluster_endpoint
      private_endpoint_url = component.hcp-consul.private_endpoint_url
      bootstrap_token = component.hcp-consul.bootstrap_token

      gossip_encrypt_key = component.hcp-consul.gossip_encrypt_key
      client_ca_cert = component.hcp-consul.client_ca_cert
      replicas = var.consul_replicas
    }

  providers = {
    kubernetes  = provider.kubernetes.oidc_configurations[each.value]
    helm  = provider.helm.oidc_configurations[each.value]
    local = provider.local.this
  }
 
}

# Deploy Hashicups K8s
component "deploy-hashicups" {
  for_each = var.regions

  source = "./hashicups-deploy"

  inputs = {
    hashicups_namespace = var.hashicups_namespaces
    ingress_public_fqdn = component.consul-deploy[each.value].ingress_public_fqdn

  }

  providers = {
    kubernetes  = provider.kubernetes.oidc_configurations[each.value]
    consul = provider.consul.configurations[each.value]
    time = provider.time.this
    local = provider.local.this
  }
}