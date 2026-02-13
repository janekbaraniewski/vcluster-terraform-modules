locals {
  test_cases = jsondecode(file("${path.module}/test_cases.json"))
}

provider "http" {
  alias = "default"
}

module "my_k8s_resource" {
  count  = length(local.test_cases)
  source = "../single-namespace-rename"

  providers = {
    http.default = http.default
  }

  host               = "https://localhost:8080"
  access_key         = "foobar"
  resource_name      = local.test_cases[count.index].resource_name
  resource_namespace = local.test_cases[count.index].namespace
  vcluster_name      = local.test_cases[count.index].vcluster_name
}

output "updated_names" {
  value = [
    for idx in range(length(local.test_cases)) : {
      resource_name = local.test_cases[idx].resource_name
      namespace     = local.test_cases[idx].namespace
      vcluster_name = local.test_cases[idx].vcluster_name
      updated_name  = module.my_k8s_resource[idx].name
    }
  ]
}
