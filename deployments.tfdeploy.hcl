identity_token "aws" {
  audience = ["terraform-stacks-private-preview"]
}


identity_token "hcp" {
  audience = ["hcp.workload.identity"]
}




deployment "development" {
  variables = {
    aws_identity_token_file = identity_token.aws.jwt_filename
    regions             = ["ap-southeast-1"]
    role_arn            = "arn:aws:iam::855831148133:role/tfstacks-role"
    vpc_name = "eks-vpc-dev2"
    vpc_cidr = "10.0.0.0/16"
    kubernetes_version = "1.28"
    # HVN specific
    workload_idp_name = "iam/project/b1b0b041-fc8d-4d11-9929-8a225d1e3ee6/service-principal/tfstacks-hcp/workload-identity-provider/tfstacks-workload-identity-provider"
    hcp_identity_token_file = identity_token.hcp.jwt_filename
    hcp_region = "ap-southeast-1"
    hcp_project_id = "b1b0b041-fc8d-4d11-9929-8a225d1e3ee6"
    deployment_id = "hvn-tfstacks"
    hvn_cidr = "172.31.0.0/16"
  }
}
