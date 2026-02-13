variable "host" {
  description = "The vCluster Platform host URL."
  type        = string
}

variable "insecure" {
  description = "Disables verification of the server's certificate chain and hostname."
  type        = bool
  default     = false
}

variable "access_key" {
  description = "vCluster Platform access key to authenticate to API"
  type        = string
}

variable "resource_name" {
  description = "Value for spec.name in the JSON payload"
  type        = string
}

variable "resource_namespace" {
  description = "Value for spec.namespace in the JSON payload"
  type        = string
}

variable "vcluster_name" {
  description = "Value for spec.vclusterName in the JSON payload"
  type        = string
}

