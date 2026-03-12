# single-namespace-rename

This module allows you to easily reference k8s resources that were synced back to host cluster by vcluster when using single namespace deployment mode.

## Usage

```hcl
provider "http" {
    alias = "default"
}

module "my_k8s_resource" {
  source        = "github.com/loft-sh/vcluster-terraform-modules//single-namespace-rename"

  providers = {
    http.default = http.default
  }


  host                = var.vcluster_platform_host
  access_key          = var.access_key
  resource_name       = var.service_account_name
  resource_namespace  = var.service_account_namespace
  vcluster_name       = var.vcluster_name
}


output "updated_name" {
  value = module.my_k8s_resource.name
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6 |
| http | >= 3.2 |

## Providers

| Name | Version |
|------|---------|
| http.default | >= 3.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [http_http.post_request](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_key | vCluster Platform access key to authenticate to API | `string` | n/a | yes |
| host | The vCluster Platform host URL. | `string` | n/a | yes |
| resource\_name | Value for spec.name in the JSON payload | `string` | n/a | yes |
| resource\_namespace | Value for spec.namespace in the JSON payload | `string` | n/a | yes |
| vcluster\_name | Value for spec.vclusterName in the JSON payload | `string` | n/a | yes |
| insecure | Disables verification of the server's certificate chain and hostname. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| name | The value of the 'name' key from the 'status' struct in the response of the POST request |
| response\_body | The full JSON response body from the POST request |
| response\_code | The HTTP response code from the POST request |
<!-- END_TF_DOCS -->
