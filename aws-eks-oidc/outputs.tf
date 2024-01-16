output "eks_token" {
  value = data.aws_eks_cluster_auth.upstream_auth.token
}

output "eks_endpoint" {
  value = data.aws_eks_cluster.upstream.endpoint
}

output "cluster_name" {
  value = data.aws_eks_cluster.upstream.id
}