resource "hcp_hvn" "hvn" {
  hvn_id         = var.deployment_id
  cloud_provider = "aws"
  region         = var.region
  cidr_block     = var.cidr
}

resource "hcp_aws_transit_gateway_attachment" "tgw" {
  depends_on = [
    var.aws_ram_resource_share_arn
  ]

  hvn_id                        = hcp_hvn.hvn.hvn_id
  transit_gateway_attachment_id = "${var.deployment_id}"
  transit_gateway_id            = var.aws_tgw_id
  resource_share_arn            = var.aws_ram_resource_share_arn
}

resource "hcp_hvn_route" "route" {
  hvn_link         = hcp_hvn.hvn.self_link
  hvn_route_id     = "${var.deployment_id}"
  destination_cidr = var.aws_vpc_cidr
  target_link      = hcp_aws_transit_gateway_attachment.tgw.self_link
}