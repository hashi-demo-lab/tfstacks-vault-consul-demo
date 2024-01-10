identity_token "aws" {
  audience = ["terraform-stacks-private-preview"]
}

deployment "development" {
  variables = {
    regions             = ["ap-southeast-1"]
    role_arn            = "arn:aws:iam::855831148133:role/tfstacks-role"
    identity_token_file = identity_token.aws.jwt_filename
    vpc_name = var.vpc_name
    vpc_cidr = var.vpc_cidr
  }
}