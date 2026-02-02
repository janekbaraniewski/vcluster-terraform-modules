variable "name" {
  description = "Name of the vCluster. Must be a valid Kubernetes resource name."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.name))
    error_message = "Must be a valid Kubernetes name: lowercase alphanumeric and hyphens, must start and end with alphanumeric."
  }

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 63
    error_message = "Must be between 1 and 63 characters."
  }
}

variable "project_name" {
  description = "vCluster Platform project name (without 'p-' prefix). Required when platform_url is set."
  type        = string
  default     = ""
  nullable    = false

  validation {
    condition     = var.project_name == "" || !startswith(var.project_name, "p-")
    error_message = "Do not include the 'p-' prefix. The module adds it automatically."
  }
}

variable "platform_url" {
  description = "URL of the vCluster Platform (e.g., https://my-platform.loft.host). Leave empty for standalone (OSS) mode."
  type        = string
  default     = ""
  nullable    = false

  validation {
    condition     = var.platform_url == "" || can(regex("^(https?://)?[a-zA-Z0-9][a-zA-Z0-9.-]+(:[0-9]+)?/?$", var.platform_url))
    error_message = "Must be a valid URL or hostname (e.g., https://my-platform.loft.host or my-platform.loft.host). Paths are not allowed."
  }
}

variable "platform_access_key" {
  description = "Access key for authenticating with the vCluster Platform API. Required when platform_url is set."
  type        = string
  default     = ""
  sensitive   = true
  nullable    = false
}

variable "namespace" {
  description = "Kubernetes namespace for the vCluster. Defaults to <name>-ns when empty."
  type        = string
  default     = ""
  nullable    = false

  validation {
    condition     = var.namespace == "" || can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.namespace))
    error_message = "When provided, must be a valid Kubernetes namespace name: lowercase alphanumeric and hyphens."
  }

  validation {
    condition     = length(var.namespace) <= 63
    error_message = "Must not exceed 63 characters."
  }
}

variable "create_namespace" {
  description = "Whether to create the Kubernetes namespace. Set to false if the namespace already exists."
  type        = bool
  default     = true
  nullable    = false
}

variable "namespace_labels" {
  description = "Additional labels to apply to the namespace. Merged with default labels (app.kubernetes.io/managed-by, app.kubernetes.io/name)."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "platform_insecure" {
  description = "Whether to skip TLS verification for platform API calls. Only use for development."
  type        = bool
  default     = false
  nullable    = false
}

variable "chart_version" {
  description = "vCluster Helm chart version to deploy. When null, the latest version from the Helm repository is used."
  type        = string
  default     = null

  validation {
    condition     = var.chart_version == null || can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+(-[a-zA-Z0-9.]+)?$", var.chart_version))
    error_message = "Must be a valid semantic version (e.g., 0.24.1 or 0.24.1-beta.1)."
  }
}

variable "helm_repository" {
  description = "Helm repository URL for the vCluster chart"
  type        = string
  default     = "https://charts.loft.sh"
  nullable    = false

  validation {
    condition     = can(regex("^(https?://|oci://)", var.helm_repository))
    error_message = "Must be a valid Helm repository URL (https:// or oci://)."
  }
}

variable "helm_chart" {
  description = "Helm chart name to deploy"
  type        = string
  default     = "vcluster"
  nullable    = false

  validation {
    condition     = length(var.helm_chart) > 0
    error_message = "Must not be empty."
  }
}

variable "helm_values" {
  description = "List of Helm values as YAML strings. Each entry is passed as a separate -f/--values argument."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "helm_timeout" {
  description = "Helm install/upgrade timeout in seconds"
  type        = number
  default     = 600
  nullable    = false

  validation {
    condition     = var.helm_timeout > 0
    error_message = "Must be a positive number."
  }
}

variable "kubeconfig_output_path" {
  description = "Filesystem path where the kubeconfig will be written. Defaults to <name>-kubeconfig.yaml in the root module directory."
  type        = string
  default     = ""
  nullable    = false
}

variable "skip_kubeconfig" {
  description = "Skip fetching kubeconfig entirely. When true, all kubeconfig-related outputs return empty values."
  type        = bool
  default     = false
  nullable    = false
}

variable "kubeconfig_secret_name" {
  description = "Name of the Kubernetes secret containing the vCluster kubeconfig (OSS mode). Defaults to 'vc-<name>' if empty."
  type        = string
  default     = ""
  nullable    = false
}

variable "retry_attempts" {
  description = "Number of retry attempts for platform API calls (kubeconfig fetch, access key fetch). Increase if vClusters take longer to become available."
  type        = number
  default     = 5
  nullable    = false

  validation {
    condition     = var.retry_attempts >= 1
    error_message = "Must be at least 1."
  }
}

variable "retry_min_delay_ms" {
  description = "Minimum delay in milliseconds between retry attempts for platform API calls."
  type        = number
  default     = 5000
  nullable    = false

  validation {
    condition     = var.retry_min_delay_ms >= 0
    error_message = "Must be non-negative."
  }
}

variable "retry_max_delay_ms" {
  description = "Maximum delay in milliseconds between retry attempts for platform API calls."
  type        = number
  default     = 15000
  nullable    = false

  validation {
    condition     = var.retry_max_delay_ms >= 0
    error_message = "Must be non-negative."
  }
}
