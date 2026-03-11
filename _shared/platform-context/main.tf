locals {
  project_namespace = var.project_name != "" ? "p-${var.project_name}" : ""
  # Ensure URL has a scheme; default to https:// if omitted
  host_with_scheme = var.platform_url != "" ? (
    length(regexall("^(http|https)://", var.platform_url)) > 0
    ? var.platform_url
    : "https://${var.platform_url}"
  ) : ""
  # Strip trailing slashes from URL
  sanitized_host = replace(local.host_with_scheme, "/\\/+$/", "")
  # Extract hostname without scheme for use in kubeconfig rewrites
  platform_host = replace(replace(local.sanitized_host, "https://", ""), "http://", "")
}
