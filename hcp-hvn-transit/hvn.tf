/* provider "hcp" {
  project_id = var.hcp_project_id
} */

resource "hcp_hvn" "hvn" {
  hvn_id         = var.deployment_id
  cloud_provider = "aws"
  region         = var.hcp_region
  cidr_block     = var.hvn_cidr
}

resource "aws_ram_resource_share" "hvn" {
  name                      = "hvn-resource-share"
  allow_external_principals = true
}

resource "aws_ram_principal_association" "example" {
  resource_share_arn = aws_ram_resource_share.hvn.arn
  principal          = hcp_hvn.hvn.provider_account_id
}

resource "aws_ram_resource_association" "example" {
  resource_share_arn = aws_ram_resource_share.hvn.arn
  resource_arn       = module.tgw.ec2_transit_gateway_arn
}


resource "hcp_aws_transit_gateway_attachment" "tgw" {

  hvn_id                        = hcp_hvn.hvn.hvn_id
  transit_gateway_attachment_id = var.deployment_id
  transit_gateway_id            = module.tgw.ec2_transit_gateway_id
  resource_share_arn            = aws_ram_resource_share.hvn.arn
}

# Need to update to handle multiple subnets/VPCs
resource "hcp_hvn_route" "route" {
  hvn_link         = hcp_hvn.hvn.self_link
  hvn_route_id     = "${var.deployment_id}"
  destination_cidr = var.aws_vpc_cidr
  target_link      = hcp_aws_transit_gateway_attachment.tgw.self_link
}

module "tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "2.8.0"

  name        = var.deployment_id

  enable_auto_accept_shared_attachments  = true
  ram_allow_external_principals          = true
  ram_principals                         = [hcp_hvn.hvn.provider_account_id]

# Need to handle multiple VPCs
  vpc_attachments = {
    vpc1 = {
      vpc_id       = var.vpc_id
      subnet_ids   = var.private_subnets
    }
  }
}

resource "aws_route" "hcp_hvn_route" {
  route_table_id            = var.route_table_id
  destination_cidr_block    = var.hvn_cidr
  transit_gateway_id        = module.tgw.ec2_transit_gateway_id
} 


#### Rules for HCP Connectivity
module "sg-consul" {
  source = "terraform-aws-modules/security-group/aws"
  version     = "4.9.0"

  name        = "${var.deployment_id}-consul"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "consul-partition-https-tcp"
      cidr_blocks = var.aws_vpc_cidr
    },
    {
      from_port   = 8300
      to_port     = 8301
      protocol    = "tcp"
      description = "consul-rpc-lan-serf-gosspip-tcp"
      cidr_blocks = var.aws_vpc_cidr
    },
    {
      from_port   = 8300
      to_port     = 8301
      protocol    = "udp"
      description = "consul-lan-serf-gosspip-udp"
      cidr_blocks = var.aws_vpc_cidr
    },
    {
      from_port   = 8443
      to_port     = 8443
      protocol    = "tcp"
      description = "consul-mesh-gateways"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8500
      to_port     = 8502
      protocol    = "tcp"
      description = "consul-http-https-api-tcp"
      cidr_blocks = var.aws_vpc_cidr
    },
    {
      from_port   = 8600
      to_port     = 8600
      protocol    = "tcp"
      description = "consul-dns-tcp"
      cidr_blocks = var.aws_vpc_cidr
    },
    {
      from_port   = 8600
      to_port     = 8600
      protocol    = "udp"
      description = "consul-dns-udp"
      cidr_blocks = var.aws_vpc_cidr
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "consul-connect-injector-tcp"
      cidr_blocks = var.aws_vpc_cidr
    },
    {
      from_port   = 20000
      to_port     = 21255
      protocol    = "tcp"
      description = "consul-connect-envoy-tcp"
      cidr_blocks = var.aws_vpc_cidr
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "any-any"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}