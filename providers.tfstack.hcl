required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.0"
  }

  hcp = {
    source  = "hashicorp/hcp"
    version = "~> 0.80.0"
  }

  cloudinit = {
    source  = "hashicorp/cloudinit"
    version = "~> 2.0"
  }

  kubernetes = {
    source  = "hashicorp/kubernetes"
    version = "~> 2.25"
  }

  time = {
    source = "hashicorp/time"
    version = "~> 0.1"
  }
  
  tls = {
    source = "hashicorp/tls"
    version = "~> 4.0"
  }

}

provider "aws" "configurations" {
  for_each = var.regions

  config {
    region = each.value

    assume_role_with_web_identity {
      role_arn                = var.role_arn
      web_identity_token_file = var.aws_identity_token_file
    }
  }
}

provider "hcp" "configuration" {

  config {
    project_id = var.hcp_project_id

    workload_identity {
      resource_name = var.workload_idp_name
      token_file = var.hcp_identity_token_file
    }
    
  }
}

provider "kubernetes" "configurations" {
  for_each = var.regions
  config { 
    host                   = component.eks[each.value].cluster_endpoint
    cluster_ca_certificate = base64decode(component.eks[each.value].cluster_certificate_authority_data)
    token   = component.eks-oidc[each.value].eks_token
  }
}

provider "cloudinit" "this" {}
provider "kubernetes" "this" {}
provider "time" "this" {}
provider "tls" "this" {}