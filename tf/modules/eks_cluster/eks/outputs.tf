output "cluster_endpoint" {
  value       = aws_eks_cluster.eks.endpoint
}

output "cluster_certificate_authority" {
  value       = aws_eks_cluster.eks.certificate_authority[0].data
}

output "cluster_name" {
  value       = aws_eks_cluster.eks.name
}

output "cluster_oidc_issuer_url" {
  value       = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

output "cluster_oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.eks.arn
}