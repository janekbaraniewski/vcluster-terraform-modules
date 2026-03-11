module "ctx" {
  source = "../_shared/platform-context"

  vcluster_name      = var.vcluster_name
  project_name       = var.project_name
  platform_url       = var.platform_url
  retry_attempts     = var.retry_attempts
  retry_min_delay_ms = var.retry_min_delay_ms
  retry_max_delay_ms = var.retry_max_delay_ms
}

locals {
  kubeconfig_path = var.output_path != "" ? var.output_path : "${path.module}/${var.vcluster_name}-kubeconfig.yaml"
}

# =============================================================================
# Fetch kubeconfig from vCluster Platform API
# =============================================================================

data "http" "kubeconfig" {
  url    = "${module.ctx.sanitized_host}/kubernetes/management/apis/management.loft.sh/v1/namespaces/${module.ctx.project_namespace}/virtualclusterinstances/${var.vcluster_name}/kubeconfig"
  method = "POST"

  request_headers = {
    "Authorization" = "Bearer ${var.platform_access_key}"
    "Content-Type"  = "application/json"
  }

  request_body = jsonencode({
    apiVersion = "management.loft.sh/v1"
    kind       = "VirtualClusterInstanceKubeConfig"
    metadata = {
      name = var.vcluster_name
    }
    spec = {
      certificateTTL = var.certificate_ttl
    }
  })

  insecure = var.platform_insecure

  retry {
    attempts     = var.retry_attempts
    min_delay_ms = var.retry_min_delay_ms
    max_delay_ms = var.retry_max_delay_ms
  }

  lifecycle {
    postcondition {
      condition     = contains([200, 201], self.status_code)
      error_message = "Platform API returned HTTP ${self.status_code} when fetching kubeconfig for vCluster '${var.vcluster_name}' in project '${var.project_name}'. Response: ${self.response_body}"
    }
    postcondition {
      condition     = can(jsondecode(self.response_body).status.kubeConfig)
      error_message = "Platform API response does not contain expected kubeconfig data at .status.kubeConfig. Response: ${self.response_body}"
    }
  }
}

# =============================================================================
# Parse and rewrite kubeconfig to use platform proxy
# =============================================================================

locals {
  kubeconfig_raw = jsondecode(data.http.kubeconfig.response_body).status.kubeConfig
  # The Platform API always returns https://localhost:8080 as the server address
  # in generated kubeconfigs. Rewrite it to the actual platform host so the
  # kubeconfig is usable outside the platform pod network.
  kubeconfig_content = replace(local.kubeconfig_raw, "https://localhost:8080", "https://${module.ctx.platform_host}")
  kubeconfig_yaml    = try(yamldecode(local.kubeconfig_content), null)
}

# =============================================================================
# Write kubeconfig file
# =============================================================================

resource "local_sensitive_file" "kubeconfig" {
  content         = local.kubeconfig_content
  filename        = local.kubeconfig_path
  file_permission = "0600"
}
