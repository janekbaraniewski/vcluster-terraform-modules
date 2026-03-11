mock_provider "http" {}
mock_provider "local" {}

override_module {
  target = module.ctx

  outputs = {
    project_namespace = "p-test-project"
    sanitized_host    = "https://platform.example.com"
    platform_host     = "platform.example.com"
  }
}

override_data {
  target = data.http.kubeconfig

  values = {
    status_code   = 200
    response_body = <<-EOT
    {
      "status": {
        "kubeConfig": "apiVersion: v1\nkind: Config\nclusters:\n- cluster:\n    server: https://localhost:8080\n    certificate-authority-data: dGVzdC1jYS1jZXJ0\n  name: vcluster\ncontexts:\n- context:\n    cluster: vcluster\n    user: vcluster\n  name: vcluster\ncurrent-context: vcluster\nusers:\n- name: vcluster\n  user:\n    client-certificate-data: dGVzdC1jbGllbnQtY2VydA==\n    client-key-data: dGVzdC1jbGllbnQta2V5\n"
      }
    }
    EOT
  }
}

run "default_kubeconfig_path" {
  command = apply

  variables {
    vcluster_name       = "test-cluster"
    project_name        = "test-project"
    platform_url        = "https://platform.example.com"
    platform_access_key = "test-access-key"
  }

  assert {
    condition     = can(regex("test-cluster-kubeconfig\\.yaml$", output.kubeconfig_path))
    error_message = "Expected default kubeconfig_path to end with 'test-cluster-kubeconfig.yaml'"
  }
}

run "custom_output_path" {
  command = apply

  variables {
    vcluster_name       = "test-cluster"
    project_name        = "test-project"
    platform_url        = "https://platform.example.com"
    platform_access_key = "test-access-key"
    output_path         = "/tmp/custom-kubeconfig.yaml"
  }

  assert {
    condition     = output.kubeconfig_path == "/tmp/custom-kubeconfig.yaml"
    error_message = "Expected kubeconfig_path to be '/tmp/custom-kubeconfig.yaml'"
  }
}

run "kubeconfig_host_rewritten" {
  command = apply

  variables {
    vcluster_name       = "test-cluster"
    project_name        = "test-project"
    platform_url        = "https://platform.example.com"
    platform_access_key = "test-access-key"
  }

  assert {
    condition     = output.host == "https://platform.example.com"
    error_message = "Expected host to be rewritten from localhost:8080 to platform host"
  }
}

run "insecure_skip_tls_verify_default" {
  command = apply

  variables {
    vcluster_name       = "test-cluster"
    project_name        = "test-project"
    platform_url        = "https://platform.example.com"
    platform_access_key = "test-access-key"
  }

  assert {
    condition     = output.insecure_skip_tls_verify == false
    error_message = "Expected insecure_skip_tls_verify to default to false"
  }
}
