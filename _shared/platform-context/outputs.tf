output "project_namespace" {
  description = "Platform project namespace with 'p-' prefix. Empty when project_name is empty."
  value       = local.project_namespace
}

output "sanitized_host" {
  description = "Platform URL with scheme added and trailing slashes removed."
  value       = local.sanitized_host
}

output "platform_host" {
  description = "Platform hostname without scheme."
  value       = local.platform_host
}
