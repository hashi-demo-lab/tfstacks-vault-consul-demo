
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

component "eks" {
  for_each = var.regions

  source = "./aws-eks-fargate"

  inputs = {
    vpc_id = component.vpc[each.value].vpc_id
    private_subnets = component.vpc[each.value].private_subnets
    kubernetes_version = var.kubernetes_version
    cluster_name = var.cluster_name
  }

  providers = {
    aws    = provider.aws.configurations[each.value]
    cloudinit = provider.cloudinit.this
    kubernetes  = provider.kubernetes.this
    time = provider.time.this
    tls = provider.tls.this
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

component "eks-oidc" {
  for_each = var.regions

  source = "./aws-eks-oidc"

  inputs = {
    cluster_name = component.eks[each.value].cluster_name
  }

  providers = {
    aws    = provider.aws.configurations[each.value]
  }
}

# Create K8s Namespace

component "k8s-namespace" {
  for_each = var.regions

  source = "./test-k8s-namespace"

  inputs = {
    cluster_name = var.cluster_name
    cluster_namespace = var.cluster_namespace
  }

  providers = {
    kubernetes  = provider.kubernetes.configurations[each.value]
    aws    = provider.aws.configurations[each.value]
  }

}

# Helm Install Consul


# Deploy Hashicups K8s
