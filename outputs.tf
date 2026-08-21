output "data_bucket_name" {
  description = "Name of the application data bucket."
  value       = aws_s3_bucket.data.bucket
}

output "trail_logs_bucket_name" {
  description = "Name of the CloudTrail destination bucket."
  value       = aws_s3_bucket.trail_logs.bucket
}

output "db_endpoint" {
  description = "Connection endpoint of the PostgreSQL instance."
  value       = aws_db_instance.workshop.endpoint
}

output "db_instance_arn" {
  description = "ARN of the PostgreSQL instance."
  value       = aws_db_instance.workshop.arn
}

output "app_security_group_id" {
  description = "ID of the application security group."
  value       = aws_security_group.app.id
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail."
  value       = aws_cloudtrail.workshop.arn
}

output "service_user_arn" {
  description = "ARN of the service IAM user."
  value       = aws_iam_user.service.arn
}

output "wildcard_policy_arn" {
  description = "ARN of the policy attached to the service user."
  value       = aws_iam_policy.wildcard.arn
}
