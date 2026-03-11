locals {
  project_namespace = var.project_name != "" ? "p-${var.project_name}" : ""
  host_with_scheme = var.platform_url != "" ? (
    length(regexall("^(http|https)://", var.platform_url)) > 0
    ? var.platform_url
    : "https://${var.platform_url}"
  ) : ""
  sanitized_host = replace(local.host_with_scheme, "/\\/+$/", "")
  platform_host  = replace(replace(local.sanitized_host, "https://", ""), "http://", "")
}
