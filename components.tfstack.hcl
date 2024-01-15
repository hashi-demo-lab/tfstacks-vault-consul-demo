
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
    route_table_id = component.vpc[var.hcp_region].route_table_id
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

#HCP CONSUL Component

# Deploy Consul to EKS - Helm and K8s

# Deploy Hashicups K8s