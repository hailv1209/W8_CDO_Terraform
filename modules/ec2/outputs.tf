output "web_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

output "web_instance_public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "web_instance_private_ip" {
  description = "Private IP of the web server"
  value       = aws_instance.web.private_ip
}

output "web_instance_arn" {
  description = "EC2 instance ARN"
  value       = aws_instance.web.arn
}

output "iam_instance_profile_name" {
  description = "IAM instance profile name"
  value       = aws_iam_instance_profile.ec2_profile.name
}
