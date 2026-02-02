output "access_key" {
  description = "Platform-issued access key for the vCluster"
  value       = local.access_key_response.accessKey
  sensitive   = true
}

output "project_namespace" {
  description = "Platform project namespace (with 'p-' prefix)"
  value       = local.project_namespace
}

output "platform_host" {
  description = "Platform hostname (without scheme)"
  value       = local.platform_host
}

output "platform_secret_name" {
  description = "Name of the Kubernetes secret created for platform credentials"
  value       = kubernetes_secret_v1.platform_api_key.metadata[0].name
}

output "vci_name" {
  description = "Name of the created VirtualClusterInstance resource"
  value       = kubernetes_manifest.virtualclusterinstance.manifest.metadata.name
}

output "completed" {
  description = "Readiness marker. Use with depends_on to sequence downstream resources."
  value       = kubernetes_secret_v1.platform_api_key.id
}
