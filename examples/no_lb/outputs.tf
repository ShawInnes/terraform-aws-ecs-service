output "task_iam_role_arn" {
  description = "ARN of the IAM Role for the ECS Task"
  value       = "${module.no_lb.task_iam_role_arn}"
}

output "task_iam_role_name" {
  description = "Name of the IAM Role for the ECS Task"
  value       = "${module.no_lb.task_iam_role_name}"
}

output "service_iam_role_arn" {
  description = "ARN of the IAM Role for the ECS Service"
  value       = "${module.no_lb.service_iam_role_arn}"
}

output "service_iam_role_name" {
  description = "Name of the IAM Role for the ECS Task"
  value       = "${module.no_lb.service_iam_role_name}"
}

output "container_json" {
  description = ""
  value       = "${module.no_lb.container_json}"
}
