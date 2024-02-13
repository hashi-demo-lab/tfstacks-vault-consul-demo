module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.2.1"

  cluster_name    = var.cluster_name
  cluster_version                = var.kubernetes_version 


  vpc_id                         = var.vpc_id
  subnet_ids                     = var.private_subnets

  cluster_endpoint_public_access = true
  enable_irsa = true

  create_cluster_security_group = true
  create_node_security_group    = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
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
              type       = "cluster"
            }
          }
        }
      }
    }
}