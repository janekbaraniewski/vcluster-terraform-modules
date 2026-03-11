mock_provider "kubernetes" {}
mock_provider "http" {}

override_module {
  target = module.ctx

  outputs = {
    project_namespace = "p-test-project"
    sanitized_host    = "https://platform.example.com"
    platform_host     = "platform.example.com"
  }
}

override_data {
  target = data.http.access_key

  values = {
    status_code   = 200
    response_body = "{\"accessKey\": \"mock-access-key-12345\"}"
  }
}

run "vci_manifest_metadata" {
  command = apply

  variables {
    vcluster_name       = "test-cluster"
    vcluster_namespace  = "test-ns"
    project_name        = "test-project"
    platform_url        = "https://platform.example.com"
    platform_access_key = "test-access-key"
  }

  assert {
    condition     = kubernetes_manifest.virtualclusterinstance.manifest.metadata.name == "test-cluster"
    error_message = "Expected VCI name to be 'test-cluster'"
  }

  assert {
    condition     = kubernetes_manifest.virtualclusterinstance.manifest.metadata.namespace == "p-test-project"
    error_message = "Expected VCI namespace to be 'p-test-project'"
  }

  assert {
    condition     = kubernetes_manifest.virtualclusterinstance.manifest.metadata.labels["app.kubernetes.io/managed-by"] == "terraform"
    error_message = "Expected managed-by label to be 'terraform'"
  }
}

run "vci_spec_flags" {
  command = apply

  variables {
    vcluster_name       = "test-cluster"
    vcluster_namespace  = "test-ns"
    project_name        = "test-project"
    platform_url        = "https://platform.example.com"
    platform_access_key = "test-access-key"
  }

  assert {
    condition     = kubernetes_manifest.virtualclusterinstance.manifest.spec.external == true
    error_message = "Expected VCI spec.external to be true"
  }

  assert {
    condition     = kubernetes_manifest.virtualclusterinstance.manifest.spec.networkPeer == true
    error_message = "Expected VCI spec.networkPeer to be true"
  }
}

run "chart_version_included" {
  command = apply

  variables {
    vcluster_name          = "test-cluster"
    vcluster_namespace     = "test-ns"
    project_name           = "test-project"
    platform_url           = "https://platform.example.com"
    platform_access_key    = "test-access-key"
    vcluster_chart_version = "0.24.1"
  }

  assert {
    condition     = kubernetes_manifest.virtualclusterinstance.manifest.spec.template.helmRelease.chart.version == "0.24.1"
    error_message = "Expected chart version to be '0.24.1'"
  }
}

run "secret_metadata" {
  command = apply

  variables {
    vcluster_name       = "test-cluster"
    vcluster_namespace  = "test-ns"
    project_name        = "test-project"
    platform_url        = "https://platform.example.com"
    platform_access_key = "test-access-key"
  }

  assert {
    condition     = kubernetes_secret_v1.platform_api_key.metadata[0].name == "vcluster-platform-api-key"
    error_message = "Expected secret name to be 'vcluster-platform-api-key'"
  }

  assert {
    condition     = kubernetes_secret_v1.platform_api_key.metadata[0].namespace == "test-ns"
    error_message = "Expected secret namespace to be 'test-ns'"
  }
}

run "secret_data_fields" {
  command = apply

  variables {
    vcluster_name       = "test-cluster"
    vcluster_namespace  = "test-ns"
    project_name        = "test-project"
    platform_url        = "https://platform.example.com"
    platform_access_key = "test-access-key"
  }

  assert {
    condition     = kubernetes_secret_v1.platform_api_key.data["host"] == "platform.example.com"
    error_message = "Expected secret host to be 'platform.example.com'"
  }

  assert {
    condition     = kubernetes_secret_v1.platform_api_key.data["project"] == "test-project"
    error_message = "Expected secret project to be 'test-project'"
  }

  assert {
    condition     = kubernetes_secret_v1.platform_api_key.data["name"] == "test-cluster"
    error_message = "Expected secret name field to be 'test-cluster'"
  }

  assert {
    condition     = kubernetes_secret_v1.platform_api_key.data["insecure"] == "false"
    error_message = "Expected secret insecure to be 'false'"
  }
}

run "output_values" {
  command = apply

  variables {
    vcluster_name       = "test-cluster"
    vcluster_namespace  = "test-ns"
    project_name        = "test-project"
    platform_url        = "https://platform.example.com"
    platform_access_key = "test-access-key"
  }

  assert {
    condition     = output.project_namespace == "p-test-project"
    error_message = "Expected project_namespace to be 'p-test-project'"
  }

  assert {
    condition     = output.platform_host == "platform.example.com"
    error_message = "Expected platform_host to be 'platform.example.com'"
  }

  assert {
    condition     = output.vci_name == "test-cluster"
    error_message = "Expected vci_name to be 'test-cluster'"
  }
}
