mock_provider "http" {
  alias = "default"

  mock_data "http" {
    defaults = {
      response_body = "{\"status\":{\"name\":\"translated-name\"}}"
      status_code   = 200
    }
  }
}

variables {
  host               = "https://my-platform.loft.host"
  access_key         = "test-access-key"
  resource_name      = "my-resource"
  resource_namespace = "my-namespace"
  vcluster_name      = "my-vcluster"
}

run "plan_with_defaults" {
  command = plan

  assert {
    condition     = local.sanitized_host == "https://my-platform.loft.host"
    error_message = "Host should be used as-is when scheme is provided"
  }

  assert {
    condition     = local.full_url == "https://my-platform.loft.host/kubernetes/management/apis/management.loft.sh/v1/translatevclusterresourcenames"
    error_message = "Full URL should combine host and resource path"
  }
}

run "host_without_scheme" {
  command = plan

  variables {
    host = "my-platform.loft.host"
  }

  assert {
    condition     = local.host_with_scheme == "https://my-platform.loft.host"
    error_message = "Host without scheme should get https:// prepended"
  }
}

run "host_with_trailing_slash" {
  command = plan

  variables {
    host = "https://my-platform.loft.host/"
  }

  assert {
    condition     = local.sanitized_host == "https://my-platform.loft.host"
    error_message = "Trailing slash should be stripped from host"
  }
}

run "http_scheme_preserved" {
  command = plan

  variables {
    host = "http://localhost:9443"
  }

  assert {
    condition     = local.host_with_scheme == "http://localhost:9443"
    error_message = "HTTP scheme should be preserved"
  }
}
