module "ctx" {
  source = "../_shared/platform-context"

  vcluster_name       = var.name
  project_name        = var.project_name
  platform_url        = var.platform_url
  platform_access_key = var.platform_access_key
  platform_insecure   = var.platform_insecure
  retry_attempts      = var.retry_attempts
  retry_min_delay_ms  = var.retry_min_delay_ms
  retry_max_delay_ms  = var.retry_max_delay_ms
}

locals {
  namespace              = var.namespace != "" ? var.namespace : "${var.name}-ns"
  kubeconfig_path        = var.kubeconfig_output_path != "" ? var.kubeconfig_output_path : "${path.root}/${var.name}-kubeconfig.yaml"
  platform_enabled       = var.platform_url != ""
  kubeconfig_secret_name = var.kubeconfig_secret_name != "" ? var.kubeconfig_secret_name : "vc-${var.name}"
}

# =============================================================================
# Create Namespace
# =============================================================================

resource "kubernetes_namespace_v1" "vcluster" {
  count = var.create_namespace ? 1 : 0

  lifecycle {
    precondition {
      condition = (
        (var.platform_url == "" && var.project_name == "" && var.platform_access_key == "") ||
        (var.platform_url != "" && var.project_name != "" && var.platform_access_key != "")
      )
      error_message = "Platform variables must be all-or-nothing: provide all of platform_url, project_name, and platform_access_key, or none of them."
    }
  }

  metadata {
    name = local.namespace
    labels = merge(
      {
        "app.kubernetes.io/managed-by" = "terraform"
        "app.kubernetes.io/name"       = var.name
      },
      var.namespace_labels
    )
  }
}

# =============================================================================
# Register with vCluster Platform (platform mode only)
# =============================================================================

module "platform_registration" {
  count  = local.platform_enabled ? 1 : 0
  source = "../vcluster-platform-registration"

  vcluster_name          = var.name
  vcluster_namespace     = local.namespace
  project_name           = var.project_name
  platform_url           = var.platform_url
  platform_access_key    = var.platform_access_key
  vcluster_chart_version = var.chart_version
  platform_insecure      = var.platform_insecure
  retry_attempts         = var.retry_attempts
  retry_min_delay_ms     = var.retry_min_delay_ms
  retry_max_delay_ms     = var.retry_max_delay_ms

  depends_on = [kubernetes_namespace_v1.vcluster]
}

# =============================================================================
# Deploy vCluster
# =============================================================================

resource "helm_release" "vcluster" {
  depends_on = [module.platform_registration]

  name             = var.name
  namespace        = local.namespace
  create_namespace = false

  repository = var.helm_repository
  chart      = var.helm_chart
  version    = var.chart_version

  values = var.helm_values

  wait          = true
  wait_for_jobs = true
  timeout       = var.helm_timeout
}

# =============================================================================
# Fetch Kubeconfig — Platform mode
# =============================================================================

module "kubeconfig" {
  count  = (!var.skip_kubeconfig && local.platform_enabled) ? 1 : 0
  source = "../vcluster-kubeconfig"

  vcluster_name       = var.name
  project_name        = var.project_name
  platform_url        = var.platform_url
  platform_access_key = var.platform_access_key
  output_path         = local.kubeconfig_path
  platform_insecure   = var.platform_insecure
  retry_attempts      = var.retry_attempts
  retry_min_delay_ms  = var.retry_min_delay_ms
  retry_max_delay_ms  = var.retry_max_delay_ms

  depends_on = [helm_release.vcluster]
}

# =============================================================================
# Fetch Kubeconfig — OSS mode (from Kubernetes secret)
# =============================================================================

data "kubernetes_secret_v1" "vcluster_kubeconfig" {
  count = (!var.skip_kubeconfig && !local.platform_enabled) ? 1 : 0

  metadata {
    name      = local.kubeconfig_secret_name
    namespace = local.namespace
  }

  depends_on = [helm_release.vcluster]
}

resource "local_sensitive_file" "kubeconfig" {
  count = (!var.skip_kubeconfig && !local.platform_enabled) ? 1 : 0

  content  = data.kubernetes_secret_v1.vcluster_kubeconfig[0].data["config"]
  filename = local.kubeconfig_path
}
