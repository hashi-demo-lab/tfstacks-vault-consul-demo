
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
  }

  providers = {
    aws    = provider.aws.configurations[each.value]
    cloudinit = provider.cloudinit.this
    kubernetes  = provider.kubernetes.this
    time = provider.time.this
    tls = provider.tls.this
  }
}

