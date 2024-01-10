identity_token "aws" {
  audience = ["terraform-stacks-private-preview"]
}

deployment "development" {
  variables = {
    regions             = ["ap-southeast-1"]
    role_arn            = "arn:aws:iam::855831148133:role/tfstacks-role"
    identity_token_file = identity_token.aws.jwt_filename
  }
}

deployment "production" {
  variables = {
    regions             = ["ap-southeast-1", "ap-southeast-2"]
    role_arn            = "arn:aws:iam::855831148133:role/tfstacks-role"
    identity_token_file = identity_token.aws.jwt_filename
  }
}

