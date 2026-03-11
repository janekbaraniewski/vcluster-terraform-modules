# -----------------------------------------------------------------------------
# URL normalization
# -----------------------------------------------------------------------------

run "adds_https_scheme_when_omitted" {
  command = plan

  variables {
    platform_url = "my-platform.loft.host"
    project_name = "default"
  }

  assert {
    condition     = output.sanitized_host == "https://my-platform.loft.host"
    error_message = "Should add https:// scheme when omitted."
  }

  assert {
    condition     = output.platform_host == "my-platform.loft.host"
    error_message = "Platform host should be hostname without scheme."
  }
}

run "preserves_existing_https_scheme" {
  command = plan

  variables {
    platform_url = "https://my-platform.loft.host"
    project_name = "default"
  }

  assert {
    condition     = output.sanitized_host == "https://my-platform.loft.host"
    error_message = "Should preserve existing https:// scheme."
  }
}

run "preserves_existing_http_scheme" {
  command = plan

  variables {
    platform_url = "http://my-platform.loft.host"
    project_name = "default"
  }

  assert {
    condition     = output.sanitized_host == "http://my-platform.loft.host"
    error_message = "Should preserve existing http:// scheme."
  }

  assert {
    condition     = output.platform_host == "my-platform.loft.host"
    error_message = "Platform host should strip http:// scheme."
  }
}

run "strips_trailing_slashes" {
  command = plan

  variables {
    platform_url = "https://my-platform.loft.host/"
    project_name = "default"
  }

  assert {
    condition     = output.sanitized_host == "https://my-platform.loft.host"
    error_message = "Should strip trailing slashes."
  }
}

run "rejects_url_with_multiple_trailing_slashes" {
  command = plan

  variables {
    platform_url = "https://my-platform.loft.host///"
    project_name = "default"
  }

  expect_failures = [
    var.platform_url,
  ]
}

# -----------------------------------------------------------------------------
# Project namespace
# -----------------------------------------------------------------------------

run "project_namespace_adds_prefix" {
  command = plan

  variables {
    platform_url = "https://platform.example.com"
    project_name = "default"
  }

  assert {
    condition     = output.project_namespace == "p-default"
    error_message = "Project namespace should have 'p-' prefix."
  }
}

run "empty_project_gives_empty_namespace" {
  command = plan

  variables {
    platform_url = "https://platform.example.com"
    project_name = ""
  }

  assert {
    condition     = output.project_namespace == ""
    error_message = "Empty project_name should produce empty project_namespace."
  }
}

run "empty_url_gives_empty_outputs" {
  command = plan

  variables {
    platform_url = ""
    project_name = ""
  }

  assert {
    condition     = output.sanitized_host == ""
    error_message = "Empty platform_url should produce empty sanitized_host."
  }

  assert {
    condition     = output.platform_host == ""
    error_message = "Empty platform_url should produce empty platform_host."
  }
}

# -----------------------------------------------------------------------------
# Variable validations
# -----------------------------------------------------------------------------

run "rejects_project_name_with_p_prefix" {
  command = plan

  variables {
    platform_url = "https://platform.example.com"
    project_name = "p-default"
  }

  expect_failures = [
    var.project_name,
  ]
}

run "rejects_invalid_vcluster_name" {
  command = plan

  variables {
    vcluster_name = "INVALID_NAME"
    platform_url  = "https://platform.example.com"
    project_name  = "default"
  }

  expect_failures = [
    var.vcluster_name,
  ]
}

run "rejects_vcluster_name_over_63_chars" {
  command = plan

  variables {
    vcluster_name = "this-name-is-way-too-long-for-a-kubernetes-resource-name-and-should-fail-validation"
    platform_url  = "https://platform.example.com"
    project_name  = "default"
  }

  expect_failures = [
    var.vcluster_name,
  ]
}

run "rejects_invalid_platform_url" {
  command = plan

  variables {
    platform_url = "not a valid url!"
    project_name = "default"
  }

  expect_failures = [
    var.platform_url,
  ]
}

run "rejects_retry_attempts_zero" {
  command = plan

  variables {
    platform_url   = "https://platform.example.com"
    project_name   = "default"
    retry_attempts = 0
  }

  expect_failures = [
    var.retry_attempts,
  ]
}

run "rejects_retry_max_less_than_min" {
  command = plan

  variables {
    platform_url       = "https://platform.example.com"
    project_name       = "default"
    retry_min_delay_ms = 10000
    retry_max_delay_ms = 1000
  }

  expect_failures = [
    var.retry_max_delay_ms,
  ]
}
