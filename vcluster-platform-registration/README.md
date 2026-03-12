# vCluster Platform Registration Module

Registers an external vCluster with the vCluster Platform, enabling Pro features via platform license.

## What it does

1. Registers the vCluster with the vCluster Platform
2. Provisions platform credentials for the vCluster
3. Stores the credentials as a Kubernetes secret in the vCluster namespace

## Prerequisites

The `VirtualClusterInstance` CRD (`management.loft.sh/v1`) must exist in the cluster before running `tofu plan`. This is a known limitation of the `kubernetes_manifest` resource, which requires CRDs to be present at plan time. The CRD is created automatically when vCluster Platform is installed.

## Usage

```hcl
module "vcluster_registration" {
  source = "git::https://github.com/loft-sh/vcluster-terraform-modules.git//vcluster-platform-registration"

  vcluster_name       = "my-vcluster"
  vcluster_namespace  = "my-vcluster-ns"
  project_name        = "default"
  platform_url        = "https://my-platform.loft.host"
  platform_access_key = var.platform_access_key
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6 |
| http | >= 3.2 |
| kubernetes | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| http | >= 3.2 |
| kubernetes | >= 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| ctx | ../_shared/platform-context | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.virtualclusterinstance](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_secret_v1.platform_api_key](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [http_http.access_key](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| platform\_access\_key | Access key for authenticating with the vCluster Platform API | `string` | n/a | yes |
| platform\_url | URL of the vCluster Platform (e.g., https://my-platform.loft.host). Scheme is added automatically if omitted. | `string` | n/a | yes |
| project\_name | vCluster Platform project name (without 'p-' prefix) | `string` | n/a | yes |
| vcluster\_name | Name of the vCluster to register with the platform | `string` | n/a | yes |
| vcluster\_namespace | Kubernetes namespace where the vCluster is deployed | `string` | n/a | yes |
| platform\_insecure | Whether to skip TLS verification for platform API calls. Only use for development. | `bool` | `false` | no |
| retry\_attempts | Number of retry attempts for the access key API call. | `number` | `5` | no |
| retry\_max\_delay\_ms | Maximum delay in milliseconds between retry attempts. | `number` | `15000` | no |
| retry\_min\_delay\_ms | Minimum delay in milliseconds between retry attempts. | `number` | `5000` | no |
| vcluster\_chart\_version | vCluster Helm chart version to record in the platform registration. When null, the version field is omitted. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| access\_key | Platform-issued access key for the vCluster |
| completed | Readiness marker. Use with depends\_on to sequence downstream resources. |
| platform\_host | Platform hostname (without scheme) |
| platform\_secret\_name | Name of the Kubernetes secret created for platform credentials |
| project\_namespace | Platform project namespace (with 'p-' prefix) |
| vci\_name | Name of the created VirtualClusterInstance resource |
<!-- END_TF_DOCS -->
