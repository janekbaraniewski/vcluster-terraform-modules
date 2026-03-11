variable "vcluster_name" {
  description = "Name of the vCluster to fetch the kubeconfig for"
  type        = string
}

variable "project_name" {
  description = "vCluster Platform project name (without 'p-' prefix)"
  type        = string
}

variable "platform_url" {
  description = "URL of the vCluster Platform (e.g., https://my-platform.loft.host). Scheme is added automatically if omitted."
  type        = string
}

variable "platform_access_key" {
  description = "Access key for authenticating with the vCluster Platform API"
  type        = string
  sensitive   = true
}

variable "output_path" {
  description = "Filesystem path where the kubeconfig file will be written. Defaults to <vcluster_name>-kubeconfig.yaml in the module directory."
  type        = string
  default     = ""
  nullable    = false
}

variable "platform_insecure" {
  description = "Whether to skip TLS verification for platform API calls. Only use for development."
  type        = bool
  default     = false
  nullable    = false
}

variable "retry_attempts" {
  description = "Number of retry attempts for the kubeconfig API call. The vCluster API may not be immediately available through the platform proxy after deployment."
  type        = number
  default     = 5
  nullable    = false
}

variable "retry_min_delay_ms" {
  description = "Minimum delay in milliseconds between retry attempts."
  type        = number
  default     = 5000
  nullable    = false
}

variable "retry_max_delay_ms" {
  description = "Maximum delay in milliseconds between retry attempts."
  type        = number
  default     = 15000
  nullable    = false
}

variable "certificate_ttl" {
  description = "TTL in seconds for the generated kubeconfig certificate. Defaults to 86400 (24 hours). Lower values are recommended for production environments."
  type        = number
  default     = 86400
  nullable    = false
}
