locals {

  tags = {
    Blueprint  = var.cluster_name
  }
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name          = var.cluster_name
  cluster_endpoint      = var.cluster_endpoint
  cluster_version       = var.cluster_version
  oidc_provider_arn     = var.oidc_provider_arn
  enable_argo_workflows = false

  # We want to wait for the Fargate profiles to be deployed first
  #create_delay_dependencies = [for prof in module.eks.fargate_profiles : prof.fargate_profile_arn]

  # EKS Add-ons
  eks_addons = {
    vpc-cni    = {}
    kube-proxy = {}
  }

  # Enable Fargate logging
  enable_fargate_fluentbit = false

  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller = {
    set = [
      {
        name  = "vpcId"
        value = var.vpc_id
      },
      {
        name  = "podDisruptionBudget.maxUnavailable"
        value = 1
      },
    ]
  }

  tags = local.tags
}