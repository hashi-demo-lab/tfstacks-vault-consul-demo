output "hvn_id" {
  description = "HVN id"
  value       = hcp_hvn.hvn.hvn_id
}

output "provider_account_id" {
  description = "HVN account id"
  value       = hcp_hvn.hvn.provider_account_id
}

output "consul_sg" {
  description = "value of the consul security group"
  value = module.sg-consul.security_group_id
}