# Wrapper module that satisfies configuration_aliases so that
# `tofu validate` can run against single-namespace-rename.
# This is NOT a real usage example — it exists only for CI validation.

terraform {
  required_version = ">= 1.6"

  required_providers {
    http = {
      source  = "hashicorp/http"
      version = ">= 3.2"
    }
  }
}

provider "http" {
  alias = "default"
}

module "sut" {
  source = "../.."
  providers = {
    http.default = http.default
  }

  host               = "https://example.com"
  access_key         = "test"
  resource_name      = "test"
  resource_namespace = "test"
  vcluster_name      = "test"
}
