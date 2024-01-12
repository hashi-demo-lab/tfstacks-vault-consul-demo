identity_token "aws" {
  audience = ["terraform-stacks-private-preview"]
}

deployment "development" {
  variables = {
    regions             = ["ap-southeast-1"]
    role_arn            = "arn:aws:iam::855831148133:role/tfstacks-role"
    identity_token_file = identity_token.aws.jwt_filename
    vpc_name = "eks-vpc-dev2"
    vpc_cidr = "10.0.0.0/16"
    kubernetes_version = "1.28"

    # HVN specific
    hcp_region = "ap-southeast-1"
    hcp_project_id = "b1b0b041-fc8d-4d11-9929-8a225d1e3ee6"
    deployment_id = "hvn-tfstacks"
    hvn_cidr = "172.31.0.0/16"
    



}
