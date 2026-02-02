# =============================================================================
# Kubeconfig File
# =============================================================================

output "kubeconfig_path" {
  description = "Filesystem path to the written kubeconfig file"
  value       = local.kubeconfig_path
}

output "kubeconfig_content" {
  description = "Raw kubeconfig YAML content"
  value       = local.kubeconfig_content
  sensitive   = true
}

output "ready" {
  description = "Readiness marker. Use with depends_on to sequence downstream resources."
  value       = local_sensitive_file.kubeconfig.id
}

# =============================================================================
# Parsed credentials for provider configuration
# =============================================================================

output "host" {
  description = "Kubernetes API server URL from the kubeconfig. Use as 'host' in provider blocks."
  value       = try(local.kubeconfig_yaml.clusters[0].cluster.server, "")
}

output "cluster_ca_certificate" {
  description = "PEM-encoded cluster CA certificate (base64-decoded from kubeconfig)"
  value       = try(base64decode(local.kubeconfig_yaml.clusters[0].cluster["certificate-authority-data"]), "")
  sensitive   = true
}

output "client_certificate" {
  description = "PEM-encoded client certificate (base64-decoded from kubeconfig)"
  value       = try(base64decode(local.kubeconfig_yaml.users[0].user["client-certificate-data"]), "")
  sensitive   = true
}

output "client_key" {
  description = "PEM-encoded client key (base64-decoded from kubeconfig)"
  value       = try(base64decode(local.kubeconfig_yaml.users[0].user["client-key-data"]), "")
  sensitive   = true
}

output "token" {
  description = "Bearer token for Kubernetes API authentication"
  value       = try(local.kubeconfig_yaml.users[0].user.token, "")
  sensitive   = true
}

output "insecure_skip_tls_verify" {
  description = "Whether TLS verification is disabled in the kubeconfig"
  value       = try(local.kubeconfig_yaml.clusters[0].cluster["insecure-skip-tls-verify"], false)
}
