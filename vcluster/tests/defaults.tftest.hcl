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

run "namespace_created_by_default" {
  command = plan

  variables {
    name                = "test-cluster"
    project_name        = "test-project"
    platform_url        = "https://platform.example.com"
    platform_access_key = "test-access-key"
  }

  assert {
    condition     = length(kubernetes_namespace_v1.vcluster) == 1
    error_message = "Expected namespace to be created when create_namespace defaults to true"
  }

  assert {
    condition     = kubernetes_namespace_v1.vcluster[0].metadata[0].name == "test-cluster-ns"
    error_message = "Expected default namespace name to be 'test-cluster-ns'"
  }
}

run "default_namespace_name" {
  command = plan

  variables {
    name                = "my-vcluster"
    project_name        = "test-project"
    platform_url        = "https://platform.example.com"
    platform_access_key = "test-access-key"
  }

  assert {
    condition     = kubernetes_namespace_v1.vcluster[0].metadata[0].name == "my-vcluster-ns"
    error_message = "Expected default namespace name to be 'my-vcluster-ns', got '${kubernetes_namespace_v1.vcluster[0].metadata[0].name}'"
  }

  assert {
    condition     = output.namespace == "my-vcluster-ns"
    error_message = "Expected namespace output to be 'my-vcluster-ns'"
  }
}

run "custom_namespace_name" {
  command = plan

  variables {
    name                = "test-cluster"
    project_name        = "test-project"
    platform_url        = "https://platform.example.com"
    platform_access_key = "test-access-key"
    namespace           = "custom-namespace"
  }

  assert {
    condition     = kubernetes_namespace_v1.vcluster[0].metadata[0].name == "custom-namespace"
    error_message = "Expected namespace name to be 'custom-namespace'"
  }

  assert {
    condition     = output.namespace == "custom-namespace"
    error_message = "Expected namespace output to be 'custom-namespace'"
  }
}

run "namespace_not_created_when_disabled" {
  command = plan

  variables {
    name                = "test-cluster"
    project_name        = "test-project"
    platform_url        = "https://platform.example.com"
    platform_access_key = "test-access-key"
    create_namespace    = false
  }

  assert {
    condition     = length(kubernetes_namespace_v1.vcluster) == 0
    error_message = "Expected no namespace to be created when create_namespace is false"
  }
}

run "namespace_labels" {
  command = plan

  variables {
    name                = "test-cluster"
    project_name        = "test-project"
    platform_url        = "https://platform.example.com"
    platform_access_key = "test-access-key"
    namespace_labels = {
      "environment" = "testing"
      "team"        = "platform"
    }
  }

  assert {
    condition     = kubernetes_namespace_v1.vcluster[0].metadata[0].labels["app.kubernetes.io/managed-by"] == "terraform"
    error_message = "Expected managed-by label to be 'terraform'"
  }

  assert {
    condition     = kubernetes_namespace_v1.vcluster[0].metadata[0].labels["app.kubernetes.io/name"] == "test-cluster"
    error_message = "Expected app name label to be 'test-cluster'"
  }

  assert {
    condition     = kubernetes_namespace_v1.vcluster[0].metadata[0].labels["environment"] == "testing"
    error_message = "Expected custom label 'environment' to be 'testing'"
  }

  assert {
    condition     = kubernetes_namespace_v1.vcluster[0].metadata[0].labels["team"] == "platform"
    error_message = "Expected custom label 'team' to be 'platform'"
  }
}

run "helm_defaults" {
  command = plan

  variables {
    name                = "test-cluster"
    project_name        = "test-project"
    platform_url        = "https://platform.example.com"
    platform_access_key = "test-access-key"
  }

  assert {
    condition     = helm_release.vcluster.name == "test-cluster"
    error_message = "Expected Helm release name to be 'test-cluster'"
  }

  assert {
    condition     = helm_release.vcluster.namespace == "test-cluster-ns"
    error_message = "Expected Helm release namespace to be 'test-cluster-ns'"
  }

  assert {
    condition     = helm_release.vcluster.chart == "vcluster"
    error_message = "Expected Helm chart to be 'vcluster'"
  }

  assert {
    condition     = helm_release.vcluster.repository == "https://charts.loft.sh"
    error_message = "Expected Helm repository to be 'https://charts.loft.sh'"
  }

  assert {
    condition     = helm_release.vcluster.create_namespace == false
    error_message = "Expected Helm release create_namespace to be false (managed separately)"
  }

  assert {
    condition     = helm_release.vcluster.timeout == 600
    error_message = "Expected Helm timeout to be 600"
  }
}

run "custom_helm_settings" {
  command = plan

  variables {
    name                = "test-cluster"
    project_name        = "test-project"
    platform_url        = "https://platform.example.com"
    platform_access_key = "test-access-key"
    chart_version       = "0.25.0"
    helm_repository     = "https://custom-charts.example.com"
    helm_chart          = "custom-vcluster"
    helm_timeout        = 300
  }

  assert {
    condition     = helm_release.vcluster.chart == "custom-vcluster"
    error_message = "Expected Helm chart to be 'custom-vcluster'"
  }

  assert {
    condition     = helm_release.vcluster.version == "0.25.0"
    error_message = "Expected Helm chart version to be '0.25.0'"
  }

  assert {
    condition     = helm_release.vcluster.repository == "https://custom-charts.example.com"
    error_message = "Expected Helm repository to be 'https://custom-charts.example.com'"
  }

  assert {
    condition     = helm_release.vcluster.timeout == 300
    error_message = "Expected Helm timeout to be 300"
  }
}

run "custom_helm_values" {
  command = plan

  variables {
    name                = "test-cluster"
    project_name        = "test-project"
    platform_url        = "https://platform.example.com"
    platform_access_key = "test-access-key"
    helm_values         = ["replicas: 3\n", "storage: 10Gi\n"]
  }

  assert {
    condition     = length(helm_release.vcluster.values) == 2
    error_message = "Expected 2 Helm values entries"
  }
}

run "output_values" {
  command = plan

  variables {
    name                = "test-cluster"
    project_name        = "test-project"
    platform_url        = "https://platform.example.com"
    platform_access_key = "test-access-key"
  }

  assert {
    condition     = output.name == "test-cluster"
    error_message = "Expected name output to be 'test-cluster'"
  }

  assert {
    condition     = output.namespace == "test-cluster-ns"
    error_message = "Expected namespace output to be 'test-cluster-ns'"
  }

  assert {
    condition     = output.project_namespace == "p-test-project"
    error_message = "Expected project_namespace output to be 'p-test-project'"
  }
}
