variable "region" {
  description = "HCP HVN region"
  type        = string
  default     = ""
}

variable "deployment_id" {
  description = "Deployment id"
  type        = string
}

variable "cidr" {
  description = "HCP HVN cidr"
  type        = string
}

variable "aws_vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "aws_tgw_id"{
  description = "AWS EC2 transit gateway id"
  type        = string
}

variable "aws_ram_resource_share_arn" {
  description = "AWS resource name (ARN) of the resource share"
  type        = string
}