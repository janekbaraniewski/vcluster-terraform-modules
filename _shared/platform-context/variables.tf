# Shared validation and normalization for platform-related variables.
# Used by: vcluster, vcluster-kubeconfig, vcluster-platform-registration.

# tflint-ignore: terraform_unused_declarations
variable "vcluster_name" {
  description = "Name of the vCluster. Must be a valid Kubernetes resource name."
  type        = string
  default     = ""

  validation {
    condition     = var.vcluster_name == "" || can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.vcluster_name))
    error_message = "Must be a valid Kubernetes name: lowercase alphanumeric and hyphens, must start and end with alphanumeric."
  }

  validation {
    condition     = length(var.vcluster_name) <= 63
    error_message = "Must not exceed 63 characters."
  }
}

variable "project_name" {
  description = "vCluster Platform project name (without 'p-' prefix)."
  type        = string
  default     = ""

  validation {
    condition     = !startswith(var.project_name, "p-")
    error_message = "Do not include the 'p-' prefix. The module adds it automatically."
  }
}

variable "platform_url" {
  description = "URL of the vCluster Platform (e.g., https://my-platform.loft.host). Scheme is added automatically if omitted."
  type        = string
  default     = ""

  validation {
    condition     = var.platform_url == "" || can(regex("^(https?://)?[a-zA-Z0-9][a-zA-Z0-9.-]+(:[0-9]+)?/?$", var.platform_url))
    error_message = "Must be a valid URL or hostname (e.g., https://my-platform.loft.host or my-platform.loft.host). Paths are not allowed."
  }
}

# tflint-ignore: terraform_unused_declarations
variable "retry_attempts" {
  description = "Number of retry attempts for platform API calls."
  type        = number
  default     = 5

  validation {
    condition     = var.retry_attempts >= 1
    error_message = "Must be at least 1."
  }
}

variable "retry_min_delay_ms" {
  description = "Minimum delay in milliseconds between retry attempts."
  type        = number
  default     = 5000

  validation {
    condition     = var.retry_min_delay_ms >= 0
    error_message = "Must be non-negative."
  }
}

# tflint-ignore: terraform_unused_declarations
variable "retry_max_delay_ms" {
  description = "Maximum delay in milliseconds between retry attempts."
  type        = number
  default     = 15000

  validation {
    condition     = var.retry_max_delay_ms >= 0
    error_message = "Must be non-negative."
  }

  validation {
    condition     = var.retry_max_delay_ms >= var.retry_min_delay_ms
    error_message = "retry_max_delay_ms must be greater than or equal to retry_min_delay_ms."
  }
}
