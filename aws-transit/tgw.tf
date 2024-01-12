module "tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "2.8.0"

  name        = var.deployment_id

  enable_auto_accept_shared_attachments  = true
  ram_allow_external_principals          = true
  ram_principals                         = [var.hcp_hvn_provider_account_id]

  vpc_attachments = {
    vpc1 = {
      vpc_id       = module.vpc.vpc_id
      subnet_ids   = module.vpc.private_subnets
    }
  }

  depends_on = [
    var.hcp_hvn_provider_account_id
  ]
}

resource "aws_route" "hcp_hvn_route" {
  route_table_id            = module.vpc.public_route_table_ids[0]
  destination_cidr_block    = var.hcp_hvn_cidr
  transit_gateway_id        = module.tgw.ec2_transit_gateway_id
}