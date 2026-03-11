locals {
  oss_kubeconfig_content = (!var.skip_kubeconfig && !local.platform_enabled) ? data.kubernetes_secret_v1.vcluster_kubeconfig[0].data["config"] : ""
}

output "name" {
  description = "Name of the vCluster"
  value       = var.name
}

output "namespace" {
  description = "Kubernetes namespace where the vCluster is deployed"
  value       = local.namespace
}

output "project_namespace" {
  description = "Platform project namespace (with 'p-' prefix). Empty when platform is not used."
  value       = local.platform_enabled ? module.platform_registration[0].project_namespace : ""
}

output "access_key" {
  description = "Platform-issued access key for the vCluster. Empty when platform is not used."
  value       = local.platform_enabled ? module.platform_registration[0].access_key : ""
  sensitive   = true
}

output "ready" {
  description = "Readiness marker. Use with depends_on to sequence downstream resources."
  value = var.skip_kubeconfig ? true : (
    local.platform_enabled ? module.kubeconfig[0].ready : local_sensitive_file.kubeconfig[0].id
  )
}

# =============================================================================
# Kubeconfig - File
# =============================================================================

output "kubeconfig_path" {
  description = "Filesystem path to the written kubeconfig file"
  value = var.skip_kubeconfig ? "" : (
    local.platform_enabled ? module.kubeconfig[0].kubeconfig_path : local_sensitive_file.kubeconfig[0].filename
  )
}

output "kubeconfig_content" {
  description = "Raw kubeconfig YAML content"
  value = var.skip_kubeconfig ? "" : (
    local.platform_enabled ? module.kubeconfig[0].kubeconfig_content : local.oss_kubeconfig_content
  )
  sensitive = true
}

# =============================================================================
# Kubeconfig - Parsed credentials for provider configuration
# =============================================================================

output "host" {
  description = "Kubernetes API server URL from the kubeconfig. Use as 'host' in provider blocks."
  value = var.skip_kubeconfig ? "" : (
    # Server URL is not secret; unwrap because source is a sensitive data source
    local.platform_enabled ? module.kubeconfig[0].host : try(nonsensitive(yamldecode(local.oss_kubeconfig_content).clusters[0].cluster.server), "")
  )
}

output "cluster_ca_certificate" {
  description = "PEM-encoded cluster CA certificate (base64-decoded)"
  value = var.skip_kubeconfig ? "" : (
    local.platform_enabled ? module.kubeconfig[0].cluster_ca_certificate : try(base64decode(yamldecode(local.oss_kubeconfig_content).clusters[0].cluster["certificate-authority-data"]), "")
  )
  sensitive = true
}

output "client_certificate" {
  description = "PEM-encoded client certificate (base64-decoded)"
  value = var.skip_kubeconfig ? "" : (
    local.platform_enabled ? module.kubeconfig[0].client_certificate : try(base64decode(yamldecode(local.oss_kubeconfig_content).users[0].user["client-certificate-data"]), "")
  )
  sensitive = true
}

output "client_key" {
  description = "PEM-encoded client key (base64-decoded)"
  value = var.skip_kubeconfig ? "" : (
    local.platform_enabled ? module.kubeconfig[0].client_key : try(base64decode(yamldecode(local.oss_kubeconfig_content).users[0].user["client-key-data"]), "")
  )
  sensitive = true
}

output "token" {
  description = "Bearer token for Kubernetes API authentication"
  value = var.skip_kubeconfig ? "" : (
    local.platform_enabled ? module.kubeconfig[0].token : try(yamldecode(local.oss_kubeconfig_content).users[0].user.token, "")
  )
  sensitive = true
}

output "insecure_skip_tls_verify" {
  description = "Whether TLS verification is disabled in the kubeconfig"
  value = var.skip_kubeconfig ? false : (
    # TLS skip flag is not secret; unwrap because source is a sensitive data source
    local.platform_enabled ? module.kubeconfig[0].insecure_skip_tls_verify : try(nonsensitive(yamldecode(local.oss_kubeconfig_content).clusters[0].cluster["insecure-skip-tls-verify"]), false)
  )
}
