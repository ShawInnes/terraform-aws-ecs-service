output "lb_dns_aliases" {
  description = "List of DNS aliases add for ALB"
  value       = "${module.route53-aliases.hostnames}"
}

output "lb_dns_name" {
  description = "FQDN of ALB provisioned for service (if present)"
  value       = "${module.lb.dns_name}"
}

output "lb_zone_id" {
  description = "Route 53 zone ID of ALB provisioned for service (if present)"
  value       = "${module.lb.zone_id}"
}

output "task_iam_role_arn" {
  description = "ARN of the IAM Role for the ECS Task"
  value       = "${element(concat(aws_iam_role.task.*.arn, list("")), 0)}"
}

output "task_iam_role_name" {
  description = "Name of the IAM Role for the ECS Task"
  value       = "${element(concat(aws_iam_role.task.*.name, list("")), 0)}"
}

output "service_iam_role_arn" {
  description = "ARN of the IAM Role for the ECS Service"
  value       = "${element(concat(aws_iam_role.service.*.arn, list("")), 0)}"
}

output "service_iam_role_name" {
  description = "Name of the IAM Role for the ECS Task"
  value       = "${element(concat(aws_iam_role.service.*.name, list("")), 0)}"
}

output "container_json" {
  description = ""
  value       = "${element(concat(data.template_file.container_definition.*.rendered, list("")), 0)}"
}
