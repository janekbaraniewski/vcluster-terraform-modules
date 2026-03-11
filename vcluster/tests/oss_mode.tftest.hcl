mock_provider "kubernetes" {}
mock_provider "helm" {}
mock_provider "http" {}
mock_provider "local" {}

override_data {
  target = data.kubernetes_secret_v1.vcluster_kubeconfig

  values = {
    data = {
      config = <<-EOT
        apiVersion: v1
        kind: Config
        clusters:
        - cluster:
            server: https://localhost:8443
            certificate-authority-data: dGVzdC1jYS1jZXJ0
          name: vcluster
        contexts:
        - context:
            cluster: vcluster
            user: vcluster
          name: vcluster
        current-context: vcluster
        users:
        - name: vcluster
          user:
            client-certificate-data: dGVzdC1jbGllbnQtY2VydA==
            client-key-data: dGVzdC1jbGllbnQta2V5
      EOT
    }
  }
}

run "oss_mode_no_platform_registration" {
  command = plan

  variables {
    name = "oss-cluster"
  }

  assert {
    condition     = length(module.platform_registration) == 0
    error_message = "Expected platform_registration module to be skipped in OSS mode"
  }

  assert {
    condition     = length(module.kubeconfig) == 0
    error_message = "Expected platform kubeconfig module to be skipped in OSS mode"
  }
}

run "oss_mode_helm_release_created" {
  command = plan

  variables {
    name = "oss-cluster"
  }

  assert {
    condition     = helm_release.vcluster.name == "oss-cluster"
    error_message = "Expected Helm release to be created in OSS mode"
  }

  assert {
    condition     = helm_release.vcluster.chart == "vcluster"
    error_message = "Expected Helm chart to be 'vcluster' in OSS mode"
  }
}

run "oss_mode_namespace_created" {
  command = plan

  variables {
    name = "oss-cluster"
  }

  assert {
    condition     = length(kubernetes_namespace_v1.vcluster) == 1
    error_message = "Expected namespace to be created in OSS mode"
  }

  assert {
    condition     = kubernetes_namespace_v1.vcluster[0].metadata[0].name == "oss-cluster-ns"
    error_message = "Expected default namespace name to be 'oss-cluster-ns'"
  }
}

run "oss_mode_kubeconfig_from_secret" {
  command = apply

  variables {
    name = "oss-cluster"
  }

  assert {
    condition     = length(data.kubernetes_secret_v1.vcluster_kubeconfig) == 1
    error_message = "Expected kubeconfig secret data source in OSS mode"
  }

  assert {
    condition     = output.host == "https://localhost:8443"
    error_message = "Expected host output to be parsed from the kubeconfig secret"
  }

  assert {
    condition     = output.kubeconfig_path != ""
    error_message = "Expected kubeconfig_path output to be set in OSS mode"
  }
}

run "oss_mode_kubeconfig_default_secret_name" {
  command = plan

  variables {
    name = "oss-cluster"
  }

  assert {
    condition     = data.kubernetes_secret_v1.vcluster_kubeconfig[0].metadata[0].name == "vc-oss-cluster"
    error_message = "Expected default kubeconfig secret name to be 'vc-oss-cluster'"
  }
}

run "oss_mode_kubeconfig_custom_secret_name" {
  command = plan

  variables {
    name                   = "oss-cluster"
    kubeconfig_secret_name = "my-custom-secret"
  }

  assert {
    condition     = data.kubernetes_secret_v1.vcluster_kubeconfig[0].metadata[0].name == "my-custom-secret"
    error_message = "Expected kubeconfig secret name to be 'my-custom-secret'"
  }
}

run "oss_mode_skip_kubeconfig" {
  command = plan

  variables {
    name            = "oss-cluster"
    skip_kubeconfig = true
  }

  assert {
    condition     = length(data.kubernetes_secret_v1.vcluster_kubeconfig) == 0
    error_message = "Expected kubeconfig secret data source to be skipped when skip_kubeconfig is true"
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
    condition     = output.ready == true
    error_message = "Expected ready output to be true when skip_kubeconfig is true"
  }
}

run "oss_mode_platform_outputs_empty" {
  command = plan

  variables {
    name = "oss-cluster"
  }

  assert {
    condition     = output.project_namespace == ""
    error_message = "Expected project_namespace to be empty in OSS mode"
  }
}
