mock_provider "kubernetes" {}
mock_provider "helm" {}
mock_provider "http" {}
mock_provider "local" {}

override_module {
  target = module.platform_registration[0]

  outputs = {
    access_key           = "mock-access-key"
    project_namespace    = "p-test-project"
    platform_host        = "platform.example.com"
    platform_secret_name = "vcluster-platform-api-key"
    vci_name             = "test-cluster"
    completed            = "mock-completed-id"
  }
}

override_module {
  target = module.kubeconfig[0]

  outputs = {
    kubeconfig_path          = "/tmp/test-cluster-kubeconfig.yaml"
    kubeconfig_content       = "mock-kubeconfig-content"
    ready                    = "mock-ready-id"
    host                     = "https://platform.example.com"
    cluster_ca_certificate   = "mock-ca-cert"
    client_certificate       = "mock-client-cert"
    client_key               = "mock-client-key"
    token                    = "mock-token"
    insecure_skip_tls_verify = false
  }
}

run "skip_kubeconfig_true" {
  command = plan

  variables {
    name                = "test-cluster"
    project_name        = "test-project"
    platform_url        = "https://platform.example.com"
    platform_access_key = "test-access-key"
    skip_kubeconfig     = true
  }

  assert {
    condition     = length(module.kubeconfig) == 0
    error_message = "Expected kubeconfig module to be skipped when skip_kubeconfig is true"
  }

  assert {
    condition     = output.kubeconfig_path == ""
    error_message = "Expected kubeconfig_path output to be empty when skip_kubeconfig is true"
  }

  assert {
    condition     = output.host == ""
    error_message = "Expected host output to be empty when skip_kubeconfig is true"
  }

  assert {
    condition     = output.insecure_skip_tls_verify == false
    error_message = "Expected insecure_skip_tls_verify output to be false when skip_kubeconfig is true"
  }

  assert {
    condition     = output.ready == true
    error_message = "Expected ready output to be true when skip_kubeconfig is true"
  }
}

run "skip_kubeconfig_false" {
  command = plan

  variables {
    name                = "test-cluster"
    project_name        = "test-project"
    platform_url        = "https://platform.example.com"
    platform_access_key = "test-access-key"
    skip_kubeconfig     = false
  }

  assert {
    condition     = length(module.kubeconfig) == 1
    error_message = "Expected kubeconfig module to be included when skip_kubeconfig is false"
  }

  assert {
    condition     = output.kubeconfig_path == "/tmp/test-cluster-kubeconfig.yaml"
    error_message = "Expected kubeconfig_path output to match mock value"
  }

  assert {
    condition     = output.host == "https://platform.example.com"
    error_message = "Expected host output to match mock value"
  }

  assert {
    condition     = output.insecure_skip_tls_verify == false
    error_message = "Expected insecure_skip_tls_verify output to match mock value"
  }
}

run "helm_release_created_with_skip_kubeconfig" {
  command = plan

  variables {
    name                = "test-cluster"
    project_name        = "test-project"
    platform_url        = "https://platform.example.com"
    platform_access_key = "test-access-key"
    skip_kubeconfig     = true
  }

  assert {
    condition     = helm_release.vcluster.name == "test-cluster"
    error_message = "Expected Helm release to still be created when skip_kubeconfig is true"
  }

  assert {
    condition     = helm_release.vcluster.chart == "vcluster"
    error_message = "Expected Helm chart to be 'vcluster' even with skip_kubeconfig"
  }
}

run "namespace_created_with_skip_kubeconfig" {
  command = plan

  variables {
    name                = "test-cluster"
    project_name        = "test-project"
    platform_url        = "https://platform.example.com"
    platform_access_key = "test-access-key"
    skip_kubeconfig     = true
    create_namespace    = true
  }

  assert {
    condition     = length(kubernetes_namespace_v1.vcluster) == 1
    error_message = "Expected namespace to be created even when skip_kubeconfig is true"
  }

  assert {
    condition     = kubernetes_namespace_v1.vcluster[0].metadata[0].name == "test-cluster-ns"
    error_message = "Expected namespace name to be 'test-cluster-ns'"
  }
}
