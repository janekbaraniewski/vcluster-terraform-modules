locals {
  project_namespace = "p-${var.project_name}"
  host_with_scheme  = length(regexall("^(http|https)://", var.platform_url)) > 0 ? var.platform_url : "https://${var.platform_url}"
  sanitized_host    = replace(local.host_with_scheme, "/\\/+$/", "")
  platform_host     = replace(replace(local.sanitized_host, "https://", ""), "http://", "")
}

# =============================================================================
# Register external virtual cluster in vCluster Platform
# =============================================================================

resource "kubernetes_manifest" "virtualclusterinstance" {
  manifest = {
    apiVersion = "management.loft.sh/v1"
    kind       = "VirtualClusterInstance"
    metadata = {
      name      = var.vcluster_name
      namespace = local.project_namespace
      labels = {
        "vcluster.loft.sh/created-by-cli" = "true"
        "app.kubernetes.io/managed-by"    = "terraform"
      }
    }
    spec = merge(
      {
        external    = true
        networkPeer = true
      },
      var.vcluster_chart_version != null ? {
        template = {
          helmRelease = {
            chart = {
              version = var.vcluster_chart_version
            }
          }
        }
      } : {}
    )
  }
}

# =============================================================================
# Fetch Access Key from Platform API
# =============================================================================

data "http" "access_key" {
  url    = "${local.sanitized_host}/kubernetes/management/apis/management.loft.sh/v1/namespaces/${local.project_namespace}/virtualclusterinstances/${var.vcluster_name}/accesskey"
  method = "GET"

  request_headers = {
    "Authorization" = "Bearer ${var.platform_access_key}"
  }

  insecure = var.platform_insecure

  depends_on = [kubernetes_manifest.virtualclusterinstance]

  retry {
    attempts     = var.retry_attempts
    min_delay_ms = var.retry_min_delay_ms
    max_delay_ms = var.retry_max_delay_ms
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Platform API returned HTTP ${self.status_code} when fetching access key for vCluster '${var.vcluster_name}' in project '${var.project_name}'. Response: ${self.response_body}"
    }
    postcondition {
      condition     = can(jsondecode(self.response_body).accessKey)
      error_message = "Platform API response does not contain expected accessKey field. Response: ${self.response_body}"
    }
  }
}

locals {
  access_key_response = jsondecode(data.http.access_key.response_body)
}

# =============================================================================
# Create Platform Secret
# =============================================================================

resource "kubernetes_secret_v1" "platform_api_key" {
  depends_on = [data.http.access_key]

  metadata {
    name      = "vcluster-platform-api-key"
    namespace = var.vcluster_namespace
    labels = {
      "vcluster.loft.sh/created-by-cli" = "true"
      "app.kubernetes.io/managed-by"    = "terraform"
    }
  }

  data = {
    accessKey = local.access_key_response.accessKey
    host      = local.platform_host
    project   = var.project_name
    insecure  = var.platform_insecure ? "true" : "false"
    name      = var.vcluster_name
  }

  type = "Opaque"
}
