variable "vcluster_name" {
  description = "Name of the vCluster to register with the platform"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.vcluster_name))
    error_message = "Must be a valid Kubernetes name: lowercase alphanumeric and hyphens, must start and end with alphanumeric."
  }

  validation {
    condition     = length(var.vcluster_name) >= 1 && length(var.vcluster_name) <= 63
    error_message = "Must be between 1 and 63 characters."
  }
}

variable "vcluster_namespace" {
  description = "Kubernetes namespace where the vCluster is deployed"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.vcluster_namespace))
    error_message = "Must be a valid Kubernetes namespace name: lowercase alphanumeric and hyphens."
  }

  validation {
    condition     = length(var.vcluster_namespace) >= 1 && length(var.vcluster_namespace) <= 63
    error_message = "Must be between 1 and 63 characters."
  }
}

variable "project_name" {
  description = "vCluster Platform project name (without 'p-' prefix)"
  type        = string

  validation {
    condition     = length(var.project_name) > 0
    error_message = "Must not be empty."
  }

  validation {
    condition     = !startswith(var.project_name, "p-")
    error_message = "Do not include the 'p-' prefix. The module adds it automatically."
  }
}

variable "platform_url" {
  description = "URL of the vCluster Platform (e.g., https://my-platform.loft.host). Scheme is added automatically if omitted."
  type        = string

  validation {
    condition     = length(var.platform_url) > 0
    error_message = "Must not be empty."
  }

  validation {
    condition     = can(regex("^(https?://)?[a-zA-Z0-9][a-zA-Z0-9.-]+(:[0-9]+)?/?$", var.platform_url))
    error_message = "Must be a valid URL or hostname (e.g., https://my-platform.loft.host or my-platform.loft.host). Paths are not allowed."
  }
}

variable "platform_access_key" {
  description = "Access key for authenticating with the vCluster Platform API"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.platform_access_key) > 0
    error_message = "Must not be empty."
  }
}

variable "vcluster_chart_version" {
  description = "vCluster Helm chart version to record in the platform registration. When null, the version field is omitted."
  type        = string
  default     = null

  validation {
    condition     = var.vcluster_chart_version == null || can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+(-[a-zA-Z0-9.]+)?$", var.vcluster_chart_version))
    error_message = "Must be a valid semantic version (e.g., 0.24.1 or 0.24.1-beta.1)."
  }
}

variable "platform_insecure" {
  description = "Whether to skip TLS verification for platform API calls. Only use for development."
  type        = bool
  default     = false
  nullable    = false
}

variable "retry_attempts" {
  description = "Number of retry attempts for the access key API call."
  type        = number
  default     = 5
  nullable    = false

  validation {
    condition     = var.retry_attempts >= 1
    error_message = "Must be at least 1."
  }
}

variable "retry_min_delay_ms" {
  description = "Minimum delay in milliseconds between retry attempts."
  type        = number
  default     = 5000
  nullable    = false

  validation {
    condition     = var.retry_min_delay_ms >= 0
    error_message = "Must be non-negative."
  }
}

variable "retry_max_delay_ms" {
  description = "Maximum delay in milliseconds between retry attempts."
  type        = number
  default     = 15000
  nullable    = false

  validation {
    condition     = var.retry_max_delay_ms >= 0
    error_message = "Must be non-negative."
  }
}
