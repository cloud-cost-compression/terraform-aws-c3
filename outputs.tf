# --- outputs.tf ---

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "evl_job_iam_role_arn" {
  description = "ARN of IAM role used by the evl job"
  value       = module.evl_job_iam_role.iam_role_arn
}