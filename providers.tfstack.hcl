required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.0"
  }

}

provider "aws" "configurations" {
  for_each = var.regions

  config {
    region = each.value

    assume_role_with_web_identity {
      role_arn                = var.role_arn
      web_identity_token_file = var.identity_token_file
    }
  }
}

