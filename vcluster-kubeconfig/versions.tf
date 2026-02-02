terraform {
  required_version = ">= 1.6"

  required_providers {
    http = {
      source  = "hashicorp/http"
      version = ">= 3.2"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0"
    }
  }
}
