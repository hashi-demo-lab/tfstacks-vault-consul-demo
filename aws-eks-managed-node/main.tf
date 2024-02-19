module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.2.1"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version


  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  cluster_endpoint_public_access = true
  enable_irsa                    = true

  create_cluster_security_group = true
  create_node_security_group    = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.large"]

      min_size     = 1
      max_size     = 4
      desired_size = 2
      vpc_security_group_ids = [var.vpc_security_group_ids]
    
    }

  }

  enable_cluster_creator_admin_permissions = true



access_entries = {
    # One access entry with a policy associated
    single = {
      kubernetes_groups = []
      principal_arn     = var.eks_clusteradmin_arn
      username          = var.eks_clusteradmin_username

      policy_associations = {
        single = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }


} 

data "aws_eks_cluster" "upstream" {
  #depends_on = [module.eks]
  name       = module.eks.cluster_name

}

data "aws_eks_cluster_auth" "upstream_auth" {
  #depends_on = [module.eks]
  name       = module.eks.cluster_name
}


resource "aws_eks_identity_provider_config" "oidc_config" {
  #depends_on   = [module.eks]
  cluster_name = module.eks.cluster_name

  oidc {
    identity_provider_config_name = "tfstack-terraform-cloud"
    client_id                     = var.tfc_kubernetes_audience
    issuer_url                    = var.tfc_hostname
    username_claim                = "sub"
    groups_claim                  = "terraform_organization_name"
  }
}

